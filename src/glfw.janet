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

  (macex1 '(c/cfunction inspect-wgpu-adapter
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
      (def desc:WGPUDeviceDescriptor)
      (set desc.nextInChain       NULL)
      (set desc.label "My Device")
      (set desc.requiredFeaturesCount 0)
      (set desc.requiredLimits NULL)
      (set desc.defaultQueue.nextInChain NULL)
      (set desc.defaultQueue.label "The default queue.")
      (def device:WGPUDevice* (requestDevice *tmpa &desc))
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

  # maybe we split this later into wjpu and jlfw
  # sticking with this for now:
  (macex1 '(c/module-entry "wjpu"))
  (file/flush f))
(file/close f)
