(use ../build/wgpu-glfw-binding)
(import spork/test :as test)

(def testname "hello triangle")
(test/start-suite testname)
(math/seedrandom (os/cryptorand 8))

(def clear-color
  @{:r (math/random)
    :g (math/random)
    :b (math/random)
    :a 1.0})
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
    [window (test/assert (create-window 640 480 testname)   "could not create window in when-with")
            |(test/assert (destroy-window $0)              (string/format "could not destroy window %q in when-with" window))]
            
    (test/assert (poll-events)                                            "could not poll for events")
    (test/assert-not (close-window? window)                (string/format "window %q was asked close just after it was created?" window))
    (with
      [instance (test/assert (wgpu-create-instance)                     "could not create wgpu instance in when-with")
               |(test/assert (wgpu-release-instance $0)  (string/format "could not destroy wgpu instance %q in when-with" instance))]
               
      (with
        [surface (test/assert (wgpu-get-surface instance window)       "could not create wgpu surface in when-with")
                |(test/assert (wgpu-release-surface $0) (string/format "could not destroy wgpu surface %q in when-with" surface))]
                
        (with
          [adapter (test/assert (wgpu-get-adapter instance surface)  "could not create wgpu adapter in when-with")
                  |(test/assert (wgpu-release-adapter $0) (string/format "could not destroy wgpu adapter %q in when-with" adapter))]
                  

                  (def feature-count (test/assert (wgpu-inspect-adapter adapter) (string/format "could not enumerate features for adapter %q" adapter)))
                  (printf "Found %q features" feature-count)
                  (with
                    [device (test/assert (wgpu-get-device adapter)               "could not create wgpu device in when-with")
                           |(test/assert (wgpu-release-device $0) (string/format "could not destroy wgpu device %q in when-with" device))]
                           
                    (test/assert
                        (wgpu-device-set-uncaptured-error-callback
                          device)                                   (string/format "could not set uncaptured error callback using wgpu device %q in when-with" device))

                    (with
                      [swapchain  (test/assert (wgpu-device-create-example-swapchain
                                                  device
                                                  adapter
                                                  surface)     (string/format "could not create swapchain using wgpu device %q adapter %q surface %q in when-with" device adapter surface))
                                 |(test/assert (wgpu-release-swapchain $0) (string/format "could not destroy swapchain %q in when-with" swapchain))]
                      (let [queue (test/assert (wgpu-device-get-queue device) (string/format "could not get queue from device %q" device))
                            shaderModule (test/assert (wgpu-device-create-shader-module device shaderSource) (string/format "could not get shaderModule from device %q for code %q" device shaderSource))
                            layout (test/assert (wgpu-device-create-example-pipeline-layout device) (string/format "could not get pipeline layout from device %q" device))
                            pipeline (test/assert (wgpu-device-create-example-render-pipeline surface adapter device layout shaderModule) (string/format "could not get pipeline for: surface %q adapter %q device %q layout %q shaderModule %q" surface adapter device layout shaderModule))
                            ]
                        (while (not (close-window? window))
                          (poll-events)
                          (def nextTexture (wgpu-swapchain-get-current-textureview swapchain))
                          # Getting the texture may fail, in particular if the window has been resized
                          # and thus the target surface changed.
                          (when (nil? nextTexture)
                            (printf "Cannot acquire next swap chain texture")
                            (break))
                          (def commandencoder (wgpu-device-create-command-encoder device))

(prin)

                          (def renderPass (wgpu-begin-example-renderpass commandencoder nextTexture clear-color))

                          (wgpu-render-pass-encoder-set-pipeline renderPass pipeline)

                          (wgpu-render-pass-encoder-draw renderPass 3 1 0 0)

                          (wgpu-render-pass-encoder-end renderPass)
                          (wgpu-release-textureview nextTexture)
                          (wgpu-command-encoder-insert-debug-marker commandencoder "hello world")
                          (def cmdbuff (wgpu-command-encoder-finish-ref commandencoder))

                          (wgpu-queue-submit queue 1 cmdbuff)
                          (wgpu-swapchain-present swapchain)
                          )
                        (test/assert (wgpu-release-shader-module shaderModule))
                        (test/assert (wgpu-release-pipeline-layout layout))
                        (test/assert (wgpu-release-render-pipeline pipeline))
                        ))))))))

  (test/end-suite)

  (os/exit)