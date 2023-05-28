(import spork/cjanet :as c)

(comment ```todo:
parse args for outfilepath, if none given use stdout.
links in comments are todos```)

(def filepath "./src/glfw.gen.c")

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
  
  (c/include "\"glfw.aux.h\"")
  #######################################
  
  (macex1 '(c/cfunction init
    :static
    ```Initializes the GLFW context,
    run once to setup the library.

    returns false on failure
    see: https://www.glfw.org/docs/latest/intro_guide.html#error_handling```
    [] -> :bool
      (return (glfwInit))))
  ##################

  (macex1 '(c/cfunction terminate
    :static
    ```Terminates the GLFW context,
    run once to shutdown the context.
    If you need GLFW afterwards, call init again to start it back up.

    If init failed, this does not have to be called.

    ---
    TODO: maybe a convenience script/macro for init+terminate? https://janet-lang.org/api/index.html#with```
    [] -> :int
      (glfwTerminate)
      (return 1)))
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
      (return (glfwCreateWindow width
                                height
                                title
                                monitor
                                share))))
  #################
  
  (macex1 '(c/cfunction destroy-window
    :static
    "calls `void glfwDestroyWindow(window)` in order to destroy window (* GLFWWindow). Returns 1, to uh.. to report the function ran properly."
    [window:pointer] -> int
      (glfwDestroyWindow window)
      (return 1)))
  #######################################
  
  (macex1 '(c/cfunction hint-next-window
    :static
    "gives hints to the next call to create-window. [keywords to be implemented](https://www.glfw.org/docs/latest/window_guide.html#window_hints)"
    [hint:int value:int] -> int
      (glfwWindowHint hint value)
      (return 1)))
  #######################################
  
  (macex1 '(c/cfunction close-window?
    :static
    "returns whether or not the window is supposed to close "
    [window:pointer] -> :bool
      (return (glfwWindowShouldClose window))))
  #######################################
  
  (macex1 '(c/cfunction poll-events
    :static
    "polls for events"
    [] -> :bool
      (glfwPollEvents)
      (return 1)))
  #######################################
  
  (macex1 '(c/cfunction wgpu-create-instance
    :static
    "returns a new wgpu instance which needs to be released/dropped via wgpu-destroy-instance"
    [] -> :pointer
      (def (desc WGPUInstanceDescriptor))
      (set desc.nextInChain NULL)
      (def instance:WGPUInstance*
        (janet_smalloc(sizeof WGPUInstance)))
      (set *instance (wgpuCreateInstance &desc))
      (return instance)))
  ###################

  (macex1 '(c/cfunction wgpu-destroy-instance
    :static
    "frees the reserved mem for the instance handle and releases or drops the instance"
    [instance:pointer] -> :int
      (def tmp:WGPUInstance* (cast WGPUInstance* instance))
      (wgpuInstanceRelease *tmp)
      (janet_sfree tmp)
      (return 1)))
  #######################################
  
  (macex1 '(c/cfunction wgpu-create-surface
    :static
    "using a WGPUInstance and GLFWwindow to create a WGPUSurface which needs to be released/dropped via wgpu-destroy-surface"
    [instance:pointer window:pointer] -> :pointer
      (def tmpi:WGPUInstance*
        (cast WGPUInstance* instance))
      (def tmpw:GLFWwindow*
        (cast GLFWwindow* window))
      (def surface:WGPUSurface*
        (janet_smalloc(sizeof WGPUSurface)))
      (set *surface (glfwGetWGPUSurface *tmpi tmpw))
      (return surface)))
  ###################

  (macex1 '(c/cfunction wgpu-destroy-surface
    :static
    "frees the reserved mem for the surface handle and releases or drops the surface"
    [surface:pointer] -> :int
      (def tmp:WGPUSurface* (cast WGPUSurface* surface))
      (wgpuSurfaceRelease *tmp)
      (janet_sfree tmp)
      (return 1)))
  #######################################


  (macex1 '(c/cfunction wgpu-create-adapter
    :static
    "using a WGPUInstance and WGPUSurface to create a WGPUAdapter which needs to be released/dropped via wgpu-destroy-adapter"
    [instance:pointer surface:pointer] -> :pointer
      (def tmpi:WGPUInstance* (cast WGPUInstance* instance))
      (def tmps:WGPUSurface*  (cast WGPUSurface* surface))
      (def adapterOptions:WGPURequestAdapterOptions)
      (set adapterOptions.nextInChain       NULL)
      (set adapterOptions.compatibleSurface (deref tmps))
      (def adapter:WGPUAdapter* (requestAdapter_smalloc *tmpi &adapterOptions))
      (return adapter)))
  ###################

  (macex1 '(c/cfunction wgpu-destroy-adapter
    :static
    "frees the reserved mem for the adapter handle and releases or drops the adapter"
    [adapter:pointer] -> :int
      (def tmp:WGPUAdapter* (cast WGPUAdapter* adapter))
      (wgpuAdapterRelease *tmp)
      (janet_sfree tmp)
      (return 1)))
  #######################################

  (macex1 '(c/cfunction wgpu-inspect-adapter
    :static
    "prints information about the adapter"
    [adapter:pointer] -> :int
      (def tmpa:WGPUAdapter*  (cast WGPUAdapter* adapter))
      (def featureCount:size_t (wgpuAdapterEnumerateFeatures *tmpa NULL))

      (def features:WGPUFeatureName* (janet_smalloc (* featureCount (sizeof WGPUFeatureName))))
      (wgpuAdapterEnumerateFeatures *tmpa features)
      (printf "Adapter features:\n")
      (def i:int)
      (for [i=0 (<= i featureCount) (++ i)]
        (switch (aref features i)
          WGPUFeatureName_Undefined               (do (printf "    Undefined\n") (break))
          WGPUFeatureName_DepthClipControl        (do (printf "    DepthClipControl\n") (break))
          WGPUFeatureName_Depth32FloatStencil8    (do (printf "    Depth32FloatStencil8\n") (break))
          WGPUFeatureName_TimestampQuery          (do (printf "    TimestampQuery\n") (break))
          WGPUFeatureName_PipelineStatisticsQuery (do (printf "    PipelineStatisticsQuery\n") (break))
          WGPUFeatureName_TextureCompressionBC    (do (printf "    TextureCompressionBC\n") (break))
          WGPUFeatureName_TextureCompressionETC2  (do (printf "    TextureCompressionETC2\n") (break))
          WGPUFeatureName_TextureCompressionASTC  (do (printf "    TextureCompressionASTC\n") (break))
          WGPUFeatureName_IndirectFirstInstance   (do (printf "    IndirectFirstInstance\n") (break))
          WGPUFeatureName_ShaderF16               (do (printf "    ShaderF16\n") (break))
          WGPUFeatureName_RG11B10UfloatRenderable (do (printf "    RG11B10UfloatRenderable\n") (break))
          WGPUFeatureName_BGRA8UnormStorage       (do (printf "    BGRA8UnormStorage\n") (break))
          WGPUFeatureName_Force32                 (do (printf "    Force32\n") (break))
          (printf "    unknown: %d\n" (aref features i))))
      (janet_sfree features)
      (return featureCount)))
    #######################################

  (macex1 '(c/cfunction wgpu-create-device
    :static
    "using a WGPUAdapter to create a WGPUDevice which needs to be released/dropped via wgpu-destroy-device"
    [adapter:pointer] -> :pointer
      (def tmpa:WGPUAdapter* (cast WGPUAdapter* adapter))
      (def deviceDescriptor:WGPUDeviceDescriptor)
      (set deviceDescriptor.nextInChain       NULL)
      (set deviceDescriptor.label "My Device")
      (set deviceDescriptor.requiredFeaturesCount 0)
      (set deviceDescriptor.requiredLimits NULL)
      (set deviceDescriptor.defaultQueue.nextInChain NULL)
      (set deviceDescriptor.defaultQueue.label "The default queue.")
      (def device:WGPUDevice* (requestDevice *tmpa &deviceDescriptor))
      (return device)))
  ###################

  (macex1 '(c/cfunction wgpu-destroy-device
    :static
    "frees the reserved mem for the device handle and releases or drops the device"
    [device:pointer] -> :int
      (def tmp:WGPUDevice* (cast WGPUDevice* device))
      (wgpuDeviceRelease *tmp)
      (janet_sfree tmp)
      (return 1)))
  #######################################

  (c/function onDeviceError_callback
    "callback for when the device encounters an error"
    [type:WGPUErrorType (message (const char*)) pUserData:void*] -> :int
      (fprintf stderr "Uncaptured device error: type %d" type)
      (if message
        (fprintf stderr message))
      (return 1))
  #######################################

  (macex1 '(c/cfunction wgpu-device-set-uncaptured-error-callback
    :static
    "gives wgpu a callback to call whenever the device encounters an error.
     will print type and message, but could receive a void pointer, which wouldnt be touched currently.

     open for suggestions for how to best exploit this for debugging <3"
    [device:pointer] -> :int
      (def tmp:WGPUDevice* (cast WGPUDevice* device))
      (def pUserData:void* NULL)
      (wgpuDeviceSetUncapturedErrorCallback *tmp onDeviceError_callback pUserData)
      (return 1)))
  #######################################

  (macex1 '(c/cfunction wgpu-device-create-queue
    :static
    ""
    [device:pointer] -> :pointer
      (def tmpd:WGPUDevice*
        (cast WGPUDevice* device))
      (def queue:WGPUQueue*
        (janet_smalloc(sizeof WGPUQueue)))
      (set *queue (wgpuDeviceGetQueue *tmpd))
      (return queue)))


  (macex1 '(c/cfunction wgpu-destroy-queue
    :static
    "frees the reserved mem for the queue handle and releases or drops the queue"
    [queue:pointer] -> :int
      (def tmp:WGPUQueue* (cast WGPUQueue* queue))
      #(wgpuQueueRelease *tmp)
      (janet_sfree tmp)
      (return 1)))


  (macex1 '(c/cfunction wgpu-device-create-swapchain
    :static
    ""
    [device:pointer adapter:pointer surface:pointer] -> :pointer
      (def tmpd:WGPUDevice*
          (cast WGPUDevice* device))
      (def tmpa:WGPUAdapter*
          (cast WGPUAdapter* adapter))
      (def tmps:WGPUSurface*
          (cast WGPUSurface* surface))
      (def (swapChainDesc WGPUSwapChainDescriptor))
      (set swapChainDesc.nextInChain NULL)
      (set swapChainDesc.width 640)
      (set swapChainDesc.height 480)
      (set swapChainDesc.format (wgpuSurfaceGetPreferredFormat *tmps *tmpa))
      (set swapChainDesc.usage WGPUTextureUsage_RenderAttachment)
      (set swapChainDesc.presentMode WGPUPresentMode_Fifo) ##Immediate ## Mailbox
      (def result:WGPUSwapChain*
        (janet_smalloc(sizeof WGPUSwapChain)))
      (set *result (wgpuDeviceCreateSwapChain *tmpd *tmps &swapChainDesc))
      (return result)))

  (macex1 '(c/cfunction wgpu-destroy-swapchain
    :static
    "frees the reserved mem for the swapchain handle and releases or drops the swapchain"
    [swapChain:pointer] -> :int
      (def tmp:WGPUSwapChain* (cast WGPUSwapChain* swapChain))
      (wgpuSwapChainRelease *tmp)
      (janet_sfree tmp)
      (return 1)))

  #wgpuSwapChainPresent(swapChain);
  (macex1 '(c/cfunction wgpu-swapchain-present
    :static
    ""
    [swapChain:pointer] -> :int
      (def tmp:WGPUSwapChain* (cast WGPUSwapChain* swapChain))
      (wgpuSwapChainPresent *tmp)
      (return 1)))

#textureview
  (macex1 '(c/cfunction wgpu-swapchain-create-next-textureview
    :static
    ""
    [swapChain:pointer] -> :pointer
      (def tmps:WGPUSwapChain*
          (cast WGPUSwapChain* swapChain))
      (def result:WGPUTextureView*
        (janet_smalloc(sizeof WGPUTextureView)))
      (set *result (wgpuSwapChainGetCurrentTextureView *tmps))
      (if !result
        (do
          (janet_sfree result)
          (return NULL))
        (return result))))

  (macex1 '(c/cfunction wgpu-destroy-textureview
    :static
    "frees the reserved mem for the swapchain handle and releases or drops the swapchain"
    [textureview:pointer] -> :int
      (if !textureview
        (do
          (def tmp:WGPUTextureView* (cast WGPUTextureView* textureview))
          (wgpuTextureViewRelease *tmp)
          (janet_sfree tmp)
          (return 1))
        (return 0))))

(macex1 '(c/cfunction wgpu-get-example-renderpass
    :static
    ""
    [encoder:pointer nextTexture:pointer] -> :pointer
      (def tmpe:WGPUCommandEncoder*
          (cast WGPUCommandEncoder* encoder))
      (def tmpt:WGPUTextureView*
          (cast WGPUTextureView* nextTexture))
      #renderPassColorAttachment
      (def (renderPassColorAttachment WGPURenderPassColorAttachment))
      # The attachment is tied to the view returned by the swapchain, so that
      # the render pass draws directly on screen.
      (set renderPassColorAttachment.view *tmpt)
      # Not relevant here because we do not use multi-sampling
      (set renderPassColorAttachment.resolveTarget NULL)
      (set renderPassColorAttachment.loadOp WGPULoadOp_Clear)
      (set renderPassColorAttachment.storeOp WGPUStoreOp_Store)
      (def (color WGPUColor))
      (set color.r 0.9)
      (set color.g 0.1)
      (set color.b 0.2)
      (set color.a 1.0)
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
      (def (renderPass WGPURenderPassEncoder*)
        (janet_smalloc(sizeof WGPURenderPassEncoder)))
      (set *renderPass (wgpuCommandEncoderBeginRenderPass *tmpe &renderPassDesc))
      (return renderPass)))

  (macex1 '(c/cfunction wgpu-render-pass-encoder-end
    :static
    "frees the reserved mem for the swapchain handle and releases or drops the swapchain"
    [renderPass:pointer] -> :int
      (def tmp:WGPURenderPassEncoder* (cast WGPURenderPassEncoder* renderPass))
      (wgpuRenderPassEncoderEnd *tmp)
      (return 1)))

  #commands:
  #command encoder to get commandbuffer:

  (macex1 '(c/cfunction wgpu-device-get-command-encoder
    :static
    ""
    [device:pointer] -> :pointer
      (def tmpd:WGPUDevice*
        (cast WGPUDevice* device))
      (def (encoderDesc WGPUCommandEncoderDescriptor))
      (set encoderDesc.nextInChain NULL)
      (set encoderDesc.label "My command encoder")
      (def result:WGPUCommandEncoder*
        (janet_smalloc(sizeof WGPUCommandEncoder)))
      (set *result (wgpuDeviceCreateCommandEncoder *tmpd &encoderDesc))
      (return result)))

  (macex1 '(c/cfunction wgpu-command-encoder-insert-debug-marker
    :static
    ""
    [encoder:pointer marker:string] -> :int
      (def tmpe:WGPUCommandEncoder*
        (cast WGPUCommandEncoder* encoder))
      (wgpuCommandEncoderInsertDebugMarker *tmpe marker)
      (return 1)))

  #WGPUCommandEncoder encoder = wgpuDeviceCreateCommandEncoder(device, &encoderDesc);
  ## https://eliemichel.github.io/LearnWebGPU/getting-started/the-command-queue.html#command-encoder


  #command encoder gives commandbuffer to store commands

  (macex1 '(c/cfunction create-command-buffer
    :static
    "allocates a pointer for the commandbuffer can be reused each frame"
    [] -> :pointer
      (return (janet_smalloc(sizeof WGPUCommandBuffer)))))

  (macex1 '(c/cfunction wgpu-command-encoder-finish-ref
    :static
    "consumes encoder, do not touch afterwards"
    [encoder:pointer cmdbuffer:pointer] -> :int
      (def tmpe:WGPUCommandEncoder*
          (cast WGPUCommandEncoder* encoder))
      (def tmpc:WGPUCommandBuffer*
          (cast WGPUCommandBuffer* cmdbuffer))
      (def (cmdBufferDescriptor WGPUCommandBufferDescriptor))
      (set cmdBufferDescriptor.nextInChain NULL)
      (set cmdBufferDescriptor.label "Command buffer")
      (set *tmpc (wgpuCommandEncoderFinish *tmpe &cmdBufferDescriptor))
      (return 1)))

  (macex1 '(c/cfunction destroy-command-buffer
    :static
    "frees the reserved mem for the commandbuffer handle"
    [commandbuffer:pointer] -> :int
      (def tmp:WGPUCommandBuffer* (cast WGPUCommandBuffer* commandbuffer))
      (janet_sfree tmp)
      (return 1)))


  #wgpuQueueSubmit(queue, /* number of commands */, /* pointer to the command array */);
  # https://eliemichel.github.io/LearnWebGPU/getting-started/the-command-queue.html#submitting-commands
  (macex1 '(c/cfunction wgpu-queue-submit
    :static
    ""
    [queue:pointer commands:int commandbuffer:pointer] -> :int
      (def tmpq:WGPUQueue*
        (cast WGPUQueue* queue))
      (def tmpc:WGPUCommandBuffer*
        (cast WGPUCommandBuffer* commandbuffer))
      (wgpuQueueSubmit *tmpq commands tmpc)
      (return 1)))


  #send RAM to VRAM:
  #wgpuQueueWriteBuffer
  #wgpuQueueWriteTexture

  #sets up callback for when work is done
  #wgpuQueueOnSubmittedWorkDone
(comment
```auto onQueueWorkDone = [](WGPUQueueWorkDoneStatus status, void* /* pUserData */) {
    std::cout << "Queued work finished with status: " << status << std::endl;
};
wgpuQueueOnSubmittedWorkDone(queue, onQueueWorkDone, nullptr /* pUserData */);

28-05-2023
https://eliemichel.github.io/LearnWebGPU/getting-started/the-command-queue.html
@993:
As of now, the wgpuQueueOnSubmittedWorkDone is not implemented by our wgpu-native backend. Using it will result in a null pointer exception so do not copy the above code block.
```
  )


  (macex1 '(c/cfunction wgpu-surface-create-preferred-format
    :static
    ""
    [surface:pointer adapter:pointer] -> :pointer
      (def tmpa:WGPUAdapter*
          (cast WGPUAdapter* adapter))
      (def tmps:WGPUSurface*
          (cast WGPUSurface* surface))
      (def result:WGPUTextureFormat*
        (janet_smalloc(sizeof WGPUTextureFormat)))
      (set *result (wgpuSurfaceGetPreferredFormat *tmps *tmpa))
      (return result)))


  (macex1 '(c/cfunction wgpu-destroy-preferred-format
    :static
    "frees the reserved mem for the preferred-format handle and releases or drops the preferred-format"
    [preferredformat:pointer] -> :int
      (def tmp:WGPUTextureFormat* (cast WGPUTextureFormat* preferredformat))
      #(wgpuTextureFormatRelease *tmp)
      (janet_sfree tmp)
      (return 1)))

  # maybe we split this later into wjpu and jlfw
  # sticking with this for now:
  (macex1 '(c/module-entry "wjpu"))
  (file/flush f))
(file/close f)
