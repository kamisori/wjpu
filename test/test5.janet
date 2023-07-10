(use ../build/wgpu-glfw-binding)
(import spork/test :as test)


(def testname "hello triangle organized in tables")
(test/start-suite testname)
(math/seedrandom (os/cryptorand 8))

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
  [context (test/assert (initialize-context)                                "could not initialize context")
          |(test/assert (terminate-context)                  (string/format "could not terminate context which was: %q" $0))]
          
  (def GLFW_CLIENT_API 0x00022001)
  (def GLFW_NO_API 0)

  (test/assert (hint-next-window GLFW_CLIENT_API GLFW_NO_API)               "could not give hint for next window")

  (def window (test/assert (create-window 640 480 testname)   "could not create window"))
  (test/assert (destroy-window nil)                                         "could not destroy nil as a window")
  (test/assert (destroy-window window)                       (string/format "could not destroy window %q" window))


  (with
    [window (test/assert (create-window 640 480 testname)   "could not create window")
            |(test/assert (destroy-window $0)              (string/format "could not destroy window %q" $0))]
            
    (test/assert (poll-events)                                            "could not poll for events")
    (test/assert-not (close-window? window)                (string/format "window %q was asked close just after it was created?" window))
    (with
      [wjpu (let [i (test/assert (wgpu-create-instance)                     "could not create wgpu instance")
                  s (test/assert (wgpu-get-surface i window)       "could not create wgpu surface")
                  a (test/assert (wgpu-get-adapter i s)  "could not create wgpu adapter")]
                 @{ :instance i
                    :surface s
                    :adapter a})
            |(let [@{ :instance i
                      :surface s
                      :adapter a} $0]
              (test/assert (wgpu-release-adapter a) (string/format "could not destroy wgpu adapter %q" a))
              (test/assert (wgpu-release-surface s) (string/format "could not destroy wgpu surface %q" s))
              (test/assert (wgpu-release-instance i)  (string/format "could not destroy wgpu instance %q" i)))]
        (def feature-count (test/assert (wgpu-inspect-adapter (wjpu :adapter)) (string/format "could not enumerate features for adapter %q" (wjpu :adapter))))
        (printf "Found %q features" feature-count)
        (with
          [wjpu (put wjpu :device (test/assert (wgpu-get-device (wjpu :adapter))               "could not create wgpu device"))
                |(test/assert (wgpu-release-device ($0 :device)) (string/format "could not destroy wgpu device %q" ($0 :device)))]
          (test/assert (wgpu-device-set-uncaptured-error-callback (wjpu :device)) (string/format "could not set uncaptured error callback using wgpu device %q" (wjpu :device)))
          (with
            [wjpu (let [device (wjpu :device)
                        adapter (wjpu :adapter)
                        surface (wjpu :surface)
                        swapchain     (test/assert (wgpu-device-create-example-swapchain device adapter surface)
                                        (string/format "could not create swapchain using wgpu device %q adapter %q surface %q"
                                          device adapter surface))
                        queue         (test/assert (wgpu-device-get-queue device)
                                        (string/format "could not get queue from device %q" device))
                        shaderModule  (test/assert (wgpu-device-create-shader-module device shaderSource)
                                        (string/format "could not get shaderModule from device %q for code %q" device shaderSource))
                        layout        (test/assert (wgpu-device-create-example-pipeline-layout device)
                                        (string/format "could not get pipeline layout from device %q" device))
                        pipeline      (test/assert (wgpu-device-create-example-render-pipeline surface adapter device layout shaderModule)
                                        (string/format "could not get pipeline for: surface %q adapter %q device %q layout %q shaderModule %q"
                                          surface adapter device layout shaderModule))]
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
                    (test/assert (wgpu-release-swapchain sc) (string/format "could not destroy swapchain %q" sc))
                    (test/assert (wgpu-release-shader-module sm))
                    (test/assert (wgpu-release-pipeline-layout rpl))
                    (test/assert (wgpu-release-render-pipeline rp)))]
              (put wjpu :clear-color  @{:r (math/random)
                                      :g (math/random)
                                      :b (math/random)
                                      :a 1.0})
              (while (not (close-window? window))
                (poll-events)
                (def nextTexture (wgpu-swapchain-get-current-textureview (wjpu :swapchain)))
                # Getting the texture may fail, in particular if the window has been resized
                # and thus the target surface changed.
                (when (nil? nextTexture)
                  (printf "Cannot acquire next swap chain texture")
                  (break))
                (def commandencoder (wgpu-device-create-command-encoder (wjpu :device)))

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
              )))))

  (os/exit)