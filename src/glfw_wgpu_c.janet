(import spork/cjanet :as c)
(import spork/tarray :as ta)

(comment ```todo:
parse args for outfilepath, if none given use stdout.
links in comments are todos```)

(def backend :wgpu-native)
(def filepath "./src/glfw_wgpu.gen.cpp")

(try
  (os/rm filepath)
  ([err] (print "err: " err)))

(def f (file/open filepath :a))
(with-dyns [*out* f]

#  (c/include <janet.h>)
#  (c/include <GLFW/glfw3.h>)
#  (c/include <webgpu/webgpu.h>)
#  see define in project.janet
#  (c/include <webgpu/webgpu-release.h>)
  
  (c/include "\"glfw.aux.hpp\"")
  #######################################
  
  (macex1 '(c/cfunction initialize-context
    :static
    ```Initializes the GLFW context,
    run once to setup the library.

    returns false on failure
    see: https://www.glfw.org/docs/latest/intro_guide.html#error_handling```
    [] -> :Janet
      (return
        (janet_wrap_boolean
            (!! (glfwInit))))))
  ##################

  (macex1 '(c/cfunction terminate-context
    :static
    ```Terminates the GLFW context,
    run once to shutdown the context.
    If you need GLFW afterwards, call init again to start it back up.

    If init failed, this does not have to be called.

    ---
    TODO: maybe a convenience script/macro for init+terminate? https://janet-lang.org/api/index.html#with```
    [] -> :Janet
      (glfwTerminate)
      (return (janet_wrap_boolean !!true))))
  #######################################

  (macex1 '(c/cfunction create-window
    :static
    ```Creates a window (* GLFWwindow)
    hosted by the previously initialized GLFW3 context.

    optionally takes a monitor (* GLFWmonitor)
    to enable true fullscreen, give a monitor you retrieved here:
    https://www.glfw.org/docs/latest/monitor_guide.html#monitor_monitors

    and a share of a window (* GLFWwindow)
    to share its context objects with:
    https://www.glfw.org/docs/latest/context_guide.html#context_sharing

    Returns a wrapped pointer to the window object inside glfwspace.```
    [width:int
     height:int
     title:cstring
     &opt (monitor :pointer NULL)
     (share :pointer NULL)] -> :pointer
      (return (cast void* (glfwCreateWindow width
                                height
                                title
                                (cast GLFWmonitor* monitor)
                                (cast GLFWwindow* share))))))
  #################
  
  (macex1 '(c/cfunction destroy-window
    :static
    "calls `void glfwDestroyWindow(window)` in order to destroy window (* GLFWWindow). Returns 1, to uh.. to report the function ran properly."
    [&opt (window :pointer NULL)] -> :Janet
      (glfwDestroyWindow (cast GLFWwindow* window))
      (return (janet_wrap_boolean !!true))))
  #######################################
  
  (macex1 '(c/cfunction hint-next-window
    :static
    "gives hints to the next call to create-window. [keywords to be implemented](https://www.glfw.org/docs/latest/window_guide.html#window_hints)"
    [hint:int value:int] -> :Janet
      (glfwWindowHint hint value)
      (return (janet_wrap_boolean !!true))))
  #######################################
  
  (macex1 '(c/cfunction close-window?
    :static
    "returns whether or not the window is supposed to close"
    [window:pointer] -> :Janet
      (return
        (janet_wrap_boolean
            (!! (glfwWindowShouldClose
              (cast GLFWwindow* window)))))))
  #######################################
  
  (macex1 '(c/cfunction poll-events
    :static
    "polls for events"
    [] -> :Janet
      (glfwPollEvents)
      (return (janet_wrap_boolean !!true))))

  ###################
  # WGPU ahead
  #######################################
  (macex1 '(c/cfunction wgpu-get-surface
    :static
    "uses a WGPUInstance and GLFWwindow to create a WGPUSurface which needs to be released via wgpu-release-surface"
    [instance:Janet window:pointer] -> :Janet
      (return
        (wrap_wgpu<WGPUSurface>
          (glfwGetWGPUSurface
            (unwrap_wgpu<WGPUInstance> instance)
            (cast GLFWwindow* window))))))
  ########################################

  (macex1 '(c/cfunction wgpu-release-surface
    :static
    "releases or drops the surface"
    [surface:Janet] -> :Janet
      (wgpuSurfaceRelease (unwrap_wgpu<WGPUSurface> surface))
      (return (janet_wrap_boolean !!true))))

  #######################################
  (macex1 '(c/cfunction wgpu-create-instance
    :static
    "returns a new wgpu instance which needs to be released via wgpu-release-instance"
    [] -> :Janet
      (def (desc WGPUInstanceDescriptor))
      (set desc.nextInChain NULL)
      (return (wrap_wgpu<WGPUInstance> (wgpuCreateInstance &desc)))))
   ###################

  (macex1 '(c/cfunction wgpu-release-instance
    :static
    "releases or drops the instance"
    [instance:Janet] -> :Janet
      (wgpuInstanceRelease (unwrap_wgpu<WGPUInstance> instance))
      (return (janet_wrap_boolean !!true))))
  #######################################

  (macex1 '(c/cfunction wgpu-get-adapter
    :static
    "uses a WGPUInstance and WGPUSurface to create a WGPUAdapter which needs to be released via wgpu-release-adapter"
    [instance:Janet surface:Janet] -> :Janet
      (def adapterOptions:WGPURequestAdapterOptions)
      (set adapterOptions.nextInChain       NULL)
      (set adapterOptions.compatibleSurface (unwrap_wgpu<WGPUSurface> surface))
      (return (requestAdapter (unwrap_wgpu<WGPUInstance> instance)
                              &adapterOptions))))
  ###################

  (macex1 '(c/cfunction wgpu-release-adapter
    :static
    "releases or drops the adapter"
    [adapter:Janet] -> :Janet
      (wgpuAdapterRelease (unwrap_wgpu<WGPUAdapter> adapter))
      (return (janet_wrap_boolean !!true))))
  #######################################

  (macex1 '(c/cfunction wgpu-inspect-adapter
    :static
    "prints information about the adapter"
    [adapter:Janet] -> :int
      (def featureCount:size_t (wgpuAdapterEnumerateFeatures (unwrap_wgpu<WGPUAdapter> adapter) NULL))
      (def buflen:size_t (* featureCount (sizeof WGPUFeatureName)))
      (def features:WGPUFeatureName* NULL)
      (set features (cast WGPUFeatureName* (janet_smalloc buflen)))
      (if (== features NULL)
        (return 0)
        (memset features 0 buflen))
      (wgpuAdapterEnumerateFeatures (unwrap_wgpu<WGPUAdapter> adapter) features)
      (printf "Adapter features:\n")
      (def i:int)
      (for [i=0 (< i featureCount) (++ i)]
        (switch (aref features i)
          WGPUFeatureName_Undefined               (do (printf " %d.   Undefined\n" i) (break))
          WGPUFeatureName_DepthClipControl        (do (printf " %d.   DepthClipControl\n" i) (break))
          WGPUFeatureName_Depth32FloatStencil8    (do (printf " %d.   Depth32FloatStencil8\n" i) (break))
          WGPUFeatureName_TimestampQuery          (do (printf " %d.   TimestampQuery\n" i) (break))
          WGPUFeatureName_PipelineStatisticsQuery (do (printf " %d.   PipelineStatisticsQuery\n" i) (break))
          WGPUFeatureName_TextureCompressionBC    (do (printf " %d.   TextureCompressionBC\n" i) (break))
          WGPUFeatureName_TextureCompressionETC2  (do (printf " %d.   TextureCompressionETC2\n" i) (break))
          WGPUFeatureName_TextureCompressionASTC  (do (printf " %d.   TextureCompressionASTC\n" i) (break))
          WGPUFeatureName_IndirectFirstInstance   (do (printf " %d.   IndirectFirstInstance\n" i) (break))
          WGPUFeatureName_ShaderF16               (do (printf " %d.   ShaderF16\n" i) (break))
          WGPUFeatureName_RG11B10UfloatRenderable (do (printf " %d.   RG11B10UfloatRenderable\n" i) (break))
          WGPUFeatureName_BGRA8UnormStorage       (do (printf " %d.   BGRA8UnormStorage\n" i) (break))
          WGPUFeatureName_Force32                 (do (printf " %d.   Force32\n" i) (break))
          (printf " %d.   unknown: %d\n" i (aref features i))))
      (janet_sfree features)
      (return featureCount)))
    #######################################

  (macex1 '(c/cfunction wgpu-get-device
    :static
    "uses a WGPUAdapter to get a WGPUDevice which needs to be released via wgpu-release-device"
    [adapter:Janet] -> :Janet
      (def deviceDescriptor:WGPUDeviceDescriptor)
      (set deviceDescriptor.nextInChain       NULL)
      (set deviceDescriptor.label "My Device")
      (set deviceDescriptor.requiredFeaturesCount 0)
      (set deviceDescriptor.requiredLimits NULL)
      (set deviceDescriptor.defaultQueue.nextInChain NULL)
      (set deviceDescriptor.defaultQueue.label "The default queue.")
      (return (requestDevice (unwrap_wgpu<WGPUAdapter> adapter)
                              &deviceDescriptor))))
  ###################

  (macex1 '(c/cfunction wgpu-release-device
    :static
    "releases or drops the device"
    [device:Janet] -> :Janet
      (wgpuDeviceRelease (unwrap_wgpu<WGPUDevice> device))
      (return (janet_wrap_boolean !!true))))
  #######################################

  (c/function onDeviceError_callback
    "callback for when the device encounters an error"
    [type:WGPUErrorType (message (const char*)) pUserData:void*] -> :void
      (fprintf stderr "Uncaptured device error: type %d" type)
      (if message
        (fprintf stderr "%s" message)))
  #######################################

  (macex1 '(c/cfunction wgpu-device-set-uncaptured-error-callback
    :static
    "gives wgpu a callback to call whenever the device encounters an error.
     will print type and message, but could receive a void pointer, which wouldnt be touched currently.

     open for suggestions for how to best exploit this for debugging <3"
    [device:Janet] -> :Janet
      (def pUserData:void* NULL)
      (wgpuDeviceSetUncapturedErrorCallback (unwrap_wgpu<WGPUDevice> device)
                                            onDeviceError_callback
                                            pUserData)
      (return (janet_wrap_boolean !!true))))
  #######################################

  (macex1 '(c/cfunction wgpu-device-get-queue
    :static
    ""
    [device:Janet] -> :Janet
      (return (wrap_wgpu<WGPUQueue>
          (wgpuDeviceGetQueue (unwrap_wgpu<WGPUDevice> device))))))

(comment
  ```
  (macex1 '(c/cfunction wgpu-release-queue
    :static
    "frees the reserved mem for the queue handle and releases or drops the queue"
    [queue:Janet] -> :Janet
      (wgpuQueueRelease (unwrap_wgpu<WGPUQueue> queue))
      (return (janet_wrap_boolean !!true))))
  ```
# apparently there is no such function wgpuQueueRelease
  )


  (macex1 '(c/cfunction wgpu-device-create-example-swapchain
    :static
    ""
    [device:Janet adapter:Janet surface:Janet] -> :Janet
      (def (swapChainDesc WGPUSwapChainDescriptor))

      (set swapChainDesc.nextInChain NULL)
      (set swapChainDesc.width 640)
      (set swapChainDesc.height 480)

      (set swapChainDesc.format
        (wgpuSurfaceGetPreferredFormat
          (unwrap_wgpu<WGPUSurface> surface)
          (unwrap_wgpu<WGPUAdapter> adapter)))

      (set swapChainDesc.usage
        WGPUTextureUsage_RenderAttachment)

      (set swapChainDesc.presentMode
        WGPUPresentMode_Fifo) ##Immediate ## Mailbox

      (return
        (wrap_wgpu<WGPUSwapChain>
          (wgpuDeviceCreateSwapChain
            (unwrap_wgpu<WGPUDevice> device)
            (unwrap_wgpu<WGPUSurface> surface)
            &swapChainDesc)))))

  (macex1 '(c/cfunction wgpu-release-swapchain
    :static
    "releases or drops the swapchain"
    [swapChain:Janet] -> :Janet
      (wgpuSwapChainRelease
        (unwrap_wgpu<WGPUSwapChain> swapChain))
      (return (janet_wrap_boolean !!true))))

  (macex1 '(c/cfunction wgpu-swapchain-present
    :static
    ""
    [swapChain:Janet] -> :Janet
      (wgpuSwapChainPresent
        (unwrap_wgpu<WGPUSwapChain> swapChain))
      (return (janet_wrap_boolean !!true))))

#textureview
  (macex1 '(c/cfunction wgpu-swapchain-get-current-textureview
    :static
    ""
    [swapChain:Janet] -> :Janet
      (return
        (wrap_wgpu<WGPUTextureView>
          (wgpuSwapChainGetCurrentTextureView
            (unwrap_wgpu<WGPUSwapChain>
              swapChain))))))

  (macex1 '(c/cfunction wgpu-release-textureview
    :static
    ""
    [textureview:Janet] -> :Janet
      (wgpuTextureViewRelease
        (unwrap_wgpu<WGPUTextureView> textureview))
      (return (janet_wrap_boolean !!true))))

(macex1 '(c/cfunction wgpu-begin-example-renderpass
    :static
    ""
    [encoder:Janet nextTexture:Janet clear_color:table] -> :Janet
      #renderPassColorAttachment
      (def (renderPassColorAttachment WGPURenderPassColorAttachment))
      # The attachment is tied to the view returned by the swapchain, so that
      # the render pass draws directly on screen.
      (set renderPassColorAttachment.view (unwrap_wgpu<WGPUTextureView> nextTexture))
      # Not relevant here because we do not use multi-sampling
      (set renderPassColorAttachment.resolveTarget NULL)
      (set renderPassColorAttachment.loadOp WGPULoadOp_Clear)
      (set renderPassColorAttachment.storeOp WGPUStoreOp_Store)
      (def (color WGPUColor))
      (set color.r (janet_unwrap_number (janet_table_get clear_color (janet_wrap_keyword (janet_keyword (cast uint8_t* "r") 1)))))
      (set color.g (janet_unwrap_number (janet_table_get clear_color (janet_wrap_keyword (janet_keyword (cast uint8_t* "g") 1)))))
      (set color.b (janet_unwrap_number (janet_table_get clear_color (janet_wrap_keyword (janet_keyword (cast uint8_t* "b") 1)))))
      (set color.a (janet_unwrap_number (janet_table_get clear_color (janet_wrap_keyword (janet_keyword (cast uint8_t* "a") 1)))))
      (set renderPassColorAttachment.clearValue color)
      
      # Describe a render pass, which targets the texture view
      (def (renderPassDesc WGPURenderPassDescriptor))
      (set renderPassDesc.colorAttachmentCount 1)
      (set renderPassDesc.colorAttachments &renderPassColorAttachment)
      # No depth buffer for now
      (set renderPassDesc.depthStencilAttachment NULL)

      # We do not use timers for now neither
      (set renderPassDesc.timestampWriteCount 0)
      (set renderPassDesc.timestampWrites NULL)

      (set renderPassDesc.nextInChain NULL)
      # Create a render pass. We end it immediately because we use its built-in
      # mechanism for clearing the screen when it begins (see descriptor).
      (return
        (wrap_wgpu<WGPURenderPassEncoder>
          (wgpuCommandEncoderBeginRenderPass
            (unwrap_wgpu<WGPUCommandEncoder> encoder)
            &renderPassDesc)))))


  (macex1 '(c/cfunction wgpu-begin-example-renderpass-UHM
    :static
    ""
    [encoder:Janet nextTexture:Janet clear_color:table] -> :Janet
      #renderPassColorAttachment
      (def (renderPassColorAttachment WGPURenderPassColorAttachment))
      # The attachment is tied to the view returned by the swapchain, so that
      # the render pass draws directly on screen.
      (set renderPassColorAttachment.view (unwrap_wgpu<WGPUTextureView> nextTexture))
      # Not relevant here because we do not use multi-sampling
      (set renderPassColorAttachment.resolveTarget NULL)
      (set renderPassColorAttachment.loadOp WGPULoadOp_Clear)
      (set renderPassColorAttachment.storeOp WGPUStoreOp_Store)
      (def (color WGPUColor))
      (set color.r (janet_unwrap_number (janet_table_get clear_color (janet_wrap_keyword (janet_keyword (cast uint8_t* "r") 1)))))
      (set color.g (janet_unwrap_number (janet_table_get clear_color (janet_wrap_keyword (janet_keyword (cast uint8_t* "g") 1)))))
      (set color.b (janet_unwrap_number (janet_table_get clear_color (janet_wrap_keyword (janet_keyword (cast uint8_t* "b") 1)))))
      (set color.a (janet_unwrap_number (janet_table_get clear_color (janet_wrap_keyword (janet_keyword (cast uint8_t* "a") 1)))))
      (set renderPassColorAttachment.clearValue color)
      
      # Describe a render pass, which targets the texture view
      (def (renderPassDesc WGPURenderPassDescriptor))
      (set renderPassDesc.colorAttachmentCount 1)
      (set renderPassDesc.colorAttachments &renderPassColorAttachment)
      # No depth buffer for now
      (set renderPassDesc.depthStencilAttachment NULL)

      # We do not use timers for now neither
      (set renderPassDesc.timestampWriteCount 0)
      (set renderPassDesc.timestampWrites NULL)

      (set renderPassDesc.nextInChain NULL)
      # Create a render pass. We end it immediately because we use its built-in
      # mechanism for clearing the screen when it begins (see descriptor).
(fprintf stderr "renderPassDesc %x\n" renderPassDesc)
      (return
        (wrap_wgpu<WGPURenderPassEncoder>
          (wgpuCommandEncoderBeginRenderPass
            (unwrap_wgpu<WGPUCommandEncoder> encoder)
            &renderPassDesc)))))

  (macex1 '(c/cfunction wgpu-render-pass-encoder-end
    :static
    ""
    [renderPass:Janet] -> :Janet
      (wgpuRenderPassEncoderEnd
        (unwrap_wgpu<WGPURenderPassEncoder> renderPass))
      (return (janet_wrap_boolean !!true))))

  (macex1 '(c/cfunction wgpu-release-render-pass-encoder
    :static
    ""
    [renderPassEncoder:Janet] -> :Janet
    (wgpuRenderPassEncoderRelease
      (unwrap_wgpu<WGPURenderPassEncoder> renderPassEncoder))
      (return (janet_wrap_boolean !!true))))

  #commands:
  #command encoder to get commandbuffer:

  (macex1 '(c/cfunction wgpu-device-create-command-encoder
    :static
    ""
    [device:Janet] -> :Janet
      (def (encoderDesc WGPUCommandEncoderDescriptor))
      (set encoderDesc.nextInChain NULL)
      (set encoderDesc.label "My command encoder")
      (return
        (wrap_wgpu<WGPUCommandEncoder>
          (wgpuDeviceCreateCommandEncoder
            (unwrap_wgpu<WGPUDevice> device)
            &encoderDesc)))))

  (macex1 '(c/cfunction wgpu-command-encoder-insert-debug-marker
    :static
    ""
    [encoder:Janet marker:cstring] -> :Janet
      (wgpuCommandEncoderInsertDebugMarker
        (unwrap_wgpu<WGPUCommandEncoder> encoder)
        marker)
      (return (janet_wrap_boolean !!true))))

  #WGPUCommandEncoder encoder = wgpuDeviceCreateCommandEncoder(device, &encoderDesc);
  ## https://eliemichel.github.io/LearnWebGPU/getting-started/the-command-queue.html#command-encoder


  #command encoder gives commandbuffer to store commands

  (macex1 '(c/cfunction wgpu-command-encoder-finish-ref
    :static
    "consumes encoder, do not touch afterwards, gives command buffer"
    [encoder:Janet] -> :Janet
      (def (cmdBufferDescriptor WGPUCommandBufferDescriptor))
      (set cmdBufferDescriptor.nextInChain NULL)
      (set cmdBufferDescriptor.label "Command buffer")
      (return
        (wrap_wgpu<WGPUCommandBuffer>
          (wgpuCommandEncoderFinish
            (unwrap_wgpu<WGPUCommandEncoder> encoder)
            &cmdBufferDescriptor)))))

  #wgpuQueueSubmit(queue, /* number of commands */, /* pointer to the command array */);
  # https://eliemichel.github.io/LearnWebGPU/getting-started/the-command-queue.html#submitting-commands
  (macex1 '(c/cfunction wgpu-queue-submit
    :static
    ""
    [queue:Janet commandCount:int commandbuffer:Janet] -> :Janet
      (def tmp:WGPUCommandBuffer (unwrap_wgpu<WGPUCommandBuffer> commandbuffer))
      (wgpuQueueSubmit
        (unwrap_wgpu<WGPUQueue> queue)
        commandCount
        (addr tmp))
      (return (janet_wrap_boolean !!true))))

(when (= backend :dawn)
  (macex1 '(c/cfunction wgpu-command-buffer-release
    :static
    "releases command buffer. only for dawn. in wgpu-native use wgpu-queue-submit"
    [commandbuffer:Janet] -> :Janet
    (wgpuCommandBufferRelease
        (unwrap_wgpu<WGPUCommandBuffer> commandbuffer))
      (return (janet_wrap_boolean !!true))
    ))

  (macex1 '(c/cfunction wgpu-command-encoder-release
    :static
    "releases command encoder. only for dawn. in wgpu-native use wgpu-command-encoder-release"
    [encoder:Janet] -> :Janet
    (wgpuCommandEncoderRelease
        (unwrap_wgpu<WGPUCommandEncoder> commandbuffer))
      (return (janet_wrap_boolean !!true))
    ))
  )

  #send RAM to VRAM:
  #wgpuQueueWriteBuffer
  #wgpuQueueWriteTexture

  #sets up callback for when work is done
  #wgpuQueueOnSubmittedWorkDone
(comment
```auto onQueueWorkDone = [](WGPUQueueWorkDoneStatus status, void* /* pUserData */) {
    std::cout << "Queued work finished with status: " << status << std::endl;
};
wgpuQueueOnSubmittedWorkDone(queue, onQueueWorkDone, NULL /* pUserData */);

28-05-2023
https://eliemichel.github.io/LearnWebGPU/getting-started/the-command-queue.html
@993:
As of now, the wgpuQueueOnSubmittedWorkDone is not implemented by our wgpu-native backend. Using it will result in a null pointer exception so do not copy the above code block.
```
  )

  (macex1 '(c/cfunction wgpu-surface-get-preferred-format
    :static
    ""
    [surface:Janet adapter:Janet] -> :Janet
      (return
        (wrap_wgpu<WGPUTextureFormat>
          (wgpuSurfaceGetPreferredFormat
            (unwrap_wgpu<WGPUSurface> surface)
            (unwrap_wgpu<WGPUAdapter> adapter))))))

  (macex1 '(c/cfunction wgpu-device-create-shader-module
    :static
    ""
    [device:Janet shaderSource:cstring] -> :Janet
      (def (shaderDesc WGPUShaderModuleDescriptor))
      (set shaderDesc.hintCount 0)
      (set shaderDesc.hints NULL)
      (def (shaderCodeDesc WGPUShaderModuleWGSLDescriptor))
      (set shaderCodeDesc.chain.next NULL)
      (set shaderCodeDesc.chain.sType WGPUSType_ShaderModuleWGSLDescriptor)
      (set shaderCodeDesc.code shaderSource)
      # in dawn: shaderCodeDesc.source
      (set shaderDesc.nextInChain &shaderCodeDesc.chain)
      (return
        (wrap_wgpu<WGPUShaderModule>
          (wgpuDeviceCreateShaderModule
            (unwrap_wgpu<WGPUDevice> device)
            (addr shaderDesc))))))

  (macex1 '(c/cfunction wgpu-release-shader-module
    :static
    ""
    [shaderModule:Janet] -> :Janet
      (wgpuShaderModuleRelease
        (unwrap_wgpu<WGPUShaderModule> shaderModule))
      (return (janet_wrap_boolean !!true))))

  (macex1 '(c/cfunction wgpu-device-create-example-pipeline-layout
    :static
    ""
    [device:Janet] -> :Janet
      # Pipeline layout
      # (Our example does not use any resource)
      (def (layoutDesc WGPUPipelineLayoutDescriptor))
      (set layoutDesc.nextInChain NULL)
      (set layoutDesc.bindGroupLayoutCount 0)
      (set layoutDesc.bindGroupLayouts NULL)
      (return
        (wrap_wgpu<WGPUPipelineLayout>
          (wgpuDeviceCreatePipelineLayout
            (unwrap_wgpu<WGPUDevice> device)
            &layoutDesc)))))

  (macex1 '(c/cfunction wgpu-release-pipeline-layout
    :static
    ""
    [pipelineLayout:Janet] -> :Janet
      (wgpuPipelineLayoutRelease
        (unwrap_wgpu<WGPUPipelineLayout> pipelineLayout))
      (return (janet_wrap_boolean !!true))))

  (macex1 '(c/cfunction wgpu-device-create-example-render-pipeline
    :static
    ""
    [surface:Janet
    adapter:Janet
    device:Janet
    pipelineLayout:Janet
    shaderModule:Janet] -> :Janet
      (def (swapChainFormat WGPUTextureFormat)
              (wgpuSurfaceGetPreferredFormat
                (unwrap_wgpu<WGPUSurface> surface)
                (unwrap_wgpu<WGPUAdapter> adapter)))
      (def (blendState WGPUBlendState))
      # Usual alpha blending for the color:
      (set blendState.color.srcFactor WGPUBlendFactor_SrcAlpha)
      (set blendState.color.dstFactor WGPUBlendFactor_OneMinusSrcAlpha)
      (set blendState.color.operation WGPUBlendOperation_Add)
      # We leave the target alpha untouched:
      (set blendState.alpha.srcFactor WGPUBlendFactor_Zero)
      (set blendState.alpha.dstFactor WGPUBlendFactor_One)
      (set blendState.alpha.operation WGPUBlendOperation_Add)

      (def (colorTarget WGPUColorTargetState))
      (set colorTarget.blend &blendState)
      (set colorTarget.nextInChain NULL)
      (set colorTarget.format swapChainFormat)
      # We could write to only some of the color channels.
      (set colorTarget.writeMask WGPUColorWriteMask_All)

      (def (fragmentState WGPUFragmentState))
      (set fragmentState.nextInChain NULL)
      (set fragmentState.module (unwrap_wgpu<WGPUShaderModule> shaderModule))
      (set fragmentState.entryPoint "fs_main")
      (set fragmentState.constantCount 0)
      (set fragmentState.constants NULL)

      # We have only one target because our render pass has only one output color
      # attachment.
      (set fragmentState.targetCount 1)
      (set fragmentState.targets &colorTarget)


      (def (pipelineDesc WGPURenderPipelineDescriptor))
      # Vertex shader
      (set pipelineDesc.vertex.module (unwrap_wgpu<WGPUShaderModule> shaderModule))
      (set pipelineDesc.vertex.entryPoint "vs_main")
      (set pipelineDesc.vertex.constantCount 0)
      (set pipelineDesc.vertex.constants NULL)
      # Vertex fetch
      # (We don't use any input buffer so far)
      (set pipelineDesc.vertex.bufferCount 0)
      (set pipelineDesc.vertex.buffers NULL)

      # Primitive assembly and rasterization
      # Each sequence of 3 vertices is considered as a triangle
      (set pipelineDesc.primitive.topology WGPUPrimitiveTopology_TriangleList)
      # We'll see later how to specify the order in which vertices should be
      # connected. When not specified, vertices are considered sequentially.
      (set pipelineDesc.primitive.stripIndexFormat WGPUIndexFormat_Undefined)
      # The face orientation is defined by assuming that when looking
      # from the front of the face, its corner vertices are enumerated
      # in the counter-clockwise (CCW) order.
      (set pipelineDesc.primitive.frontFace WGPUFrontFace_CCW)
      # But the face orientation does not matter much because we do not
      # cull (i.e. "hide") the faces pointing away from us (which is often
      # used for optimization).
      (set pipelineDesc.primitive.cullMode WGPUCullMode_None)

      # Depth and stencil tests are not used here
      (set pipelineDesc.depthStencil NULL)

      # Multi-sampling
      # Samples per pixel
      (set pipelineDesc.multisample.count 1)
      # Default value for the mask, meaning "all bits on"
      (set pipelineDesc.multisample.mask (cast uint32_t -1))
      # Default value as well (irrelevant for count 1 anyways)
      (set pipelineDesc.multisample.alphaToCoverageEnabled :false)

      (set pipelineDesc.fragment &fragmentState)
      (set pipelineDesc.layout (unwrap_wgpu<WGPUPipelineLayout> pipelineLayout))
      (return (wrap_wgpu<WGPURenderPipeline>
          (wgpuDeviceCreateRenderPipeline
            (unwrap_wgpu<WGPUDevice> device)
                            (addr pipelineDesc))
                          ))))

  (macex1 '(c/cfunction wgpu-release-render-pipeline
    :static
    ""
    [renderPipeline:Janet] -> :Janet
      (wgpuRenderPipelineRelease
        (unwrap_wgpu<WGPURenderPipeline> renderPipeline))
      (return (janet_wrap_boolean !!true))))

  (macex1 '(c/cfunction wgpu-render-pass-encoder-set-pipeline
    :static
    ""
    [renderPass:Janet pipeline:Janet] -> :Janet
      (wgpuRenderPassEncoderSetPipeline
        (unwrap_wgpu<WGPURenderPassEncoder> renderPass)
        (unwrap_wgpu<WGPURenderPipeline> pipeline))
      (return (janet_wrap_boolean !!true))))

  (macex1 '(c/cfunction wgpu-render-pass-encoder-draw
    :static
    "this should be enough most of the time and easier to handle, but if you actually need uint32 bits here use the variant for that"
##void wgpuRenderPassEncoderDraw(WGPURenderPassEncoder renderPassEncoder, uint32_t vertexCount, uint32_t instanceCount, uint32_t firstVertex, uint32_t firstInstance);
    [renderPass:Janet vertexCount:int instanceCount:int firstVertex:int firstInstance:int] -> :Janet
      (wgpuRenderPassEncoderDraw
        (unwrap_wgpu<WGPURenderPassEncoder> renderPass)
        vertexCount instanceCount firstVertex firstInstance)
      (return (janet_wrap_boolean !!true))))

  (macex1 '(c/cfunction wgpu-render-pass-encoder-draw-uint32
    :static
    "uint32 variant that takes uint64 values and casts those down to uint32"
##void wgpuRenderPassEncoderDraw(WGPURenderPassEncoder renderPassEncoder, uint32_t vertexCount, uint32_t instanceCount, uint32_t firstVertex, uint32_t firstInstance);
    [renderPass:Janet vertexCount:uint64 instanceCount:uint64 firstVertex:uint64 firstInstance:uint64] -> :Janet
      (wgpuRenderPassEncoderDraw
        (unwrap_wgpu<WGPURenderPassEncoder> renderPass)
        (cast uint32_t vertexCount)
        (cast uint32_t instanceCount)
        (cast uint32_t firstVertex)
        (cast uint32_t firstInstance))
      (return (janet_wrap_boolean !!true))))

  (macex1 '(c/cfunction wgpu-device-create-example-buffer1
    :static
    ""
    [device:Janet] -> :Janet
      (def (bufferDesc WGPUBufferDescriptor))
      (set bufferDesc.nextInChain NULL)
      (set bufferDesc.label "Some GPU-side data buffer")
      (set bufferDesc.usage (bor WGPUBufferUsage_CopyDst WGPUBufferUsage_CopySrc))
      (set bufferDesc.size 16)
      (set bufferDesc.mappedAtCreation !true)
      (return
        (wrap_wgpu<WGPUBuffer>
          (wgpuDeviceCreateBuffer
            (unwrap_wgpu<WGPUDevice> device)
            (addr bufferDesc))))))

    (macex1 '(c/cfunction wgpu-device-create-example-buffer2
    :static
    ""
    [device:Janet] -> :Janet
      (def (bufferDesc WGPUBufferDescriptor))
      (set bufferDesc.nextInChain NULL)
      (set bufferDesc.label "Some GPU-side data buffer")
      (set bufferDesc.usage (bor WGPUBufferUsage_CopyDst WGPUBufferUsage_MapRead))
      (set bufferDesc.size 16)
      (set bufferDesc.mappedAtCreation !true)
      (return
        (wrap_wgpu<WGPUBuffer>
          (wgpuDeviceCreateBuffer
            (unwrap_wgpu<WGPUDevice> device)
            (addr bufferDesc))))))

  (macex1 '(c/cfunction wgpu-release-buffer
    :static
    ""
    [buffer:Janet] -> :Janet
      (wgpuBufferRelease
        (unwrap_wgpu<WGPUBuffer> buffer))
      (return (janet_wrap_boolean !!true))))

  (macex1 '(c/cfunction wgpu-destroy-buffer
    :static
    ""
    [buffer:Janet] -> :Janet
      (wgpuBufferDestroy
        (unwrap_wgpu<WGPUBuffer> buffer))
      (return (janet_wrap_boolean !!true))))

  (macex1 '(c/cfunction wgpu-queue-write-buffer
    :static
    ""
    [queue:Janet buffer:Janet bufferOffset:uint64 tarray_data:Janet buffersize:uint64] -> :Janet
    (def (tmp void*) (janet_unwrap_abstract tarray_data))
    
    # always panics:
    # error: bad slot #3, expected ta/view, got <ta/view 0x0298F15EE8D0>
    # (if (!= (janet_abstract_type tmp) &janet_ta_view_type)
    #   (janet_panic_abstract tarray_data 3 &janet_ta_view_type))

    (def (data JanetTArrayView*) (cast JanetTArrayView* tmp))
    (wgpuQueueWriteBuffer
      (unwrap_wgpu<WGPUQueue> queue)
      (unwrap_wgpu<WGPUBuffer> buffer)
      bufferOffset
      data->as.u8
      buffersize)
    (return (janet_wrap_boolean !!true))))


  (macex1 '(c/cfunction wgpu-command-encoder-copy-buffer-to-buffer
    :static
    ""
    [commandEncoder:Janet source:Janet sourceOffset:uint64 destination:Janet destinationOffset:uint64 size:uint64] -> :Janet
    (wgpuCommandEncoderCopyBufferToBuffer
      (unwrap_wgpu<WGPUCommandEncoder> commandEncoder)
      (unwrap_wgpu<WGPUBuffer> source)
      sourceOffset
      (unwrap_wgpu<WGPUBuffer> destination)
      destinationOffset
      size)
    (return (janet_wrap_boolean !!true))))

  (c/function onBufferMapped_print_status_callback
    "callback for when the buffer is mapped"
    [status:WGPUBufferMapAsyncStatus  pUserData:void*] -> :void
      (printf "Buffer mapped with status %d\n" status))

  (c/function onBufferMapped_print_buffer_callback
    "callback for when the buffer is mapped"
    [status:WGPUBufferMapAsyncStatus  pUserData:void*] -> :void
      (def (a_buffer WGPUBuffer) (cast WGPUBuffer pUserData))
      (printf "Buffer mapped with status %d\n" status)
      (if (== status WGPUBufferMapAsyncStatus_Success)
        (do
          (def (bufferData uint8_t*) (cast uint8_t* (wgpuBufferGetMappedRange a_buffer 0 16)))
          (printf "bufferData = [")
          (def i:int)
          (for [i=0 (< i 16) (++ i)]
            (if (> i 0)
              (printf ", "))
            (printf "%d" (aref bufferData i)))
          (printf "]\n")
          (wgpuBufferUnmap a_buffer))))

#void wgpuBufferMapAsync(WGPUBuffer buffer, WGPUMapModeFlags mode, size_t offset, size_t size, WGPUBufferMapCallback callback, void * userdata);
  (macex1 '(c/cfunction wgpu-buffer-map-async-print-status
    :static
    ""
    [buffer:Janet mode:Janet offset:uint64 size:uint64] -> :Janet
    (wgpuBufferMapAsync
      (unwrap_wgpu<WGPUBuffer> buffer)
      WGPUMapMode_Read #
      offset
      size
      onBufferMapped_print_status_callback #
      NULL) #
    (return (janet_wrap_boolean !!true))))

  #void wgpuBufferMapAsync(WGPUBuffer buffer, WGPUMapModeFlags mode, size_t offset, size_t size, WGPUBufferMapCallback callback, void * userdata);
  (macex1 '(c/cfunction wgpu-buffer-map-async-print-buffer
    :static
    ""
    [buffer:Janet mode:Janet offset:uint64 size:uint64] -> :Janet
    (wgpuBufferMapAsync
      (unwrap_wgpu<WGPUBuffer> buffer)
      WGPUMapMode_Read #
      offset
      size
      onBufferMapped_print_buffer_callback #
      (cast void* (unwrap_wgpu<WGPUBuffer> buffer))) #
    (return (janet_wrap_boolean !!true))))


#https://eliemichel.github.io/LearnWebGPU/basic-3d-rendering/input-geometry/playing-with-buffers.html
#gotta test mapping context

##https://eliemichel.github.io/LearnWebGPU/basic-3d-rendering/input-geometry/a-first-vertex-attribute.html

  (macex1 '(c/module-entry "glfw-wgpu-cjanet"))
  (file/flush f))
(file/close f)

# step 025 has good points about janeteering/janetizing this:
# https://eliemichel.github.io/LearnWebGPU/getting-started/cpp-idioms.html
