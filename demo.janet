(use ./build/wgpu-glfw-binding)
(import spork/test :as test)
(import spork/tarray :as ta)


(defn get-next-color [old-color]
    (let [@{:r r
            :g g
            :b b
            :a a
            :dir dir} old-color
          step 0.01]
    (if (= dir :up)
      (if (< r 1.0)
        @{:r (+ r step) :g g :b b :a a :dir dir}
        (if (< g 1.0)
          @{:r 1.0 :g (+ g step) :b b :a a :dir dir}
          (if (< b 1.0)
            @{:r 1.0 :g 1.0 :b (+ b step) :a a :dir dir}
            @{:r 1.0 :g 1.0 :b 1.0 :a a :dir :down})))
      (if (> r 0.0)
        @{:r (- r step) :g g :b b :a a :dir dir}
        (if (> g 0.0)
          @{:r 0.0 :g (- g step) :b b :a a :dir dir}
          (if (> b 0.0)
            @{:r 0.0 :g 0.0 :b (- b step) :a a :dir dir}
            @{:r 0.0 :g 0.0 :b 0.0 :a a :dir :up}))))))

(defn- main [&]
  (math/seedrandom (os/cryptorand 8))
  (def testname "hello triangle organized in tables")

  (def shaderSource ```
  @vertex
  fn vs_main(@builtin(vertex_index) in_vertex_index: u32) -> @builtin(position) vec4<f32> {
    var p = vec2<f32>(0.0, 0.0);
    if (in_vertex_index == 0u) {
      p = vec2<f32>(-0.5, -0.5);
    } else if (in_vertex_index == 1u) {
      p = vec2<f32>(0.5, -0.5);
    } else {
      p = vec2<f32>(0.0, 0.5);
    }
    return vec4<f32>(p, 0.0, 1.0);
  }

  @fragment
  fn fs_main() -> @location(0) vec4<f32> {
      return vec4<f32>(0.0, 0.4, 1.0, 1.0);
  }
  ```)

  (with
    [context (initialize-context)
            |(do (pp $0) (terminate-context))]
            
    (def GLFW_CLIENT_API 0x00022001)
    (def GLFW_NO_API 0)

    (hint-next-window GLFW_CLIENT_API GLFW_NO_API)

    (with
      [window (create-window 640 480 testname)
              |(destroy-window $0)]
      (with
        [wjpu (let [i (wgpu-create-instance)
                    s (wgpu-get-surface i window)
                    a (wgpu-get-adapter i s)]
                   @{ :instance i
                      :surface s
                      :adapter a})
              |(let [@{ :instance i
                        :surface s
                        :adapter a} $0]
                (wgpu-release-adapter a)
                (wgpu-release-surface s)
                (wgpu-release-instance i))]
          (def feature-count (wgpu-inspect-adapter (wjpu :adapter)) )
          (printf "Found %q features" feature-count)
          (with
            [wjpu (put wjpu :device (wgpu-get-device (wjpu :adapter)))
                  |(wgpu-release-device ($0 :device))]
            (wgpu-device-set-uncaptured-error-callback (wjpu :device))
            (with
              [wjpu (let [device (wjpu :device)
                          adapter (wjpu :adapter)
                          surface (wjpu :surface)
                          swapchain     (wgpu-device-create-example-swapchain device adapter surface)
                          queue         (wgpu-device-get-queue device)
                          shaderModule  (wgpu-device-create-shader-module device shaderSource)
                          layout        (wgpu-device-create-example-pipeline-layout device)
                          pipeline      (wgpu-device-create-example-render-pipeline surface adapter device layout shaderModule)]
                      (-> wjpu 
                        (put :swapchain swapchain)
                        (put :queue queue)
                        (put :shader-module shaderModule)
                        (put :render-pipeline-layout layout)
                        (put :render-pipeline pipeline)))
                    |(let [@{ :swapchain sc
                              :shader-module sm
                              :render-pipeline-layout rpl
                              :render-pipeline rp} $0]
                      (wgpu-release-swapchain sc)
                      (wgpu-release-shader-module sm)
                      (wgpu-release-pipeline-layout rpl)
                      (wgpu-release-render-pipeline rp))]
                (let [buffer1 (wgpu-device-create-example-buffer1 (wjpu :device))
                      buffer2 (wgpu-device-create-example-buffer2 (wjpu :device))
                      data (ta/new :uint8 16)
                      ]
                  (put wjpu :clear-color  @{:r (math/random)
                                          :g (math/random)
                                          :b (math/random)
                                          :a 1.0})
                  (for i 0 (ta/length data)
                    (set (data i) i))
                  (pp data)
                  (var graceperiod 1)
                  (wgpu-queue-write-buffer (wjpu :queue) buffer1 0 data (ta/length data))
                  (while (not (close-window? window))
                    (poll-events)
                    (def nextTexture (wgpu-swapchain-get-current-textureview (wjpu :swapchain)))
                    # Getting the texture may fail, in particular if the window has been resized
                    # and thus the target surface changed.
                    (when (nil? nextTexture)
                      (printf "Cannot acquire next swap chain texture")
                      (break))
                    (def commandencoder (wgpu-device-create-command-encoder (wjpu :device)))
                    (set graceperiod (+ graceperiod 1))
                    (when (= 100 graceperiod)
                      (wgpu-command-encoder-copy-buffer-to-buffer commandencoder buffer1 0 buffer2 0 (ta/length data))
                      )

                    (when (= 200 graceperiod)
                      (wgpu-buffer-map-async-print-buffer buffer2 :mode 0 (ta/length data))
                      )

                    (put wjpu :clear-color (get-next-color (wjpu :clear-color)))

                    (def renderPass (wgpu-begin-example-renderpass-UHM commandencoder nextTexture (wjpu :clear-color)))

                    (wgpu-render-pass-encoder-set-pipeline renderPass (wjpu :render-pipeline))

                    (wgpu-render-pass-encoder-draw renderPass 3 1 0 0)

                    (wgpu-render-pass-encoder-end renderPass)
                    (wgpu-release-textureview nextTexture)
                    (wgpu-command-encoder-insert-debug-marker commandencoder "hello world")
                    (def cmdbuff (wgpu-command-encoder-finish-ref commandencoder))

                    (wgpu-queue-submit (wjpu :queue) 1 cmdbuff)
                    (wgpu-swapchain-present (wjpu :swapchain))
                    )
                  (wgpu-destroy-buffer buffer1)
                  (wgpu-destroy-buffer buffer2)
                  (wgpu-release-buffer buffer1)
                  (wgpu-release-buffer buffer2)
                  )))))))