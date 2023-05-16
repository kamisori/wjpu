(import spork/cjanet :as c)

(comment ```todo:
parse args for outfilepath, if none given use stdout.
links in comments are todos```)

(def filepath "./src/generated/glfw.c")

(try
  (os/rm filepath)
  ([err] (print "err: " err)))

(def f (file/open filepath :a))
(with-dyns [*out* f]

  (c/include <janet.h>)
  
  (c/include <GLFW/glfw3.h>)
  (c/include <webgpu/webgpu.h>)
  # see define in project.janet
  (c/include <webgpu/webgpu-release.h>)
  
  (macex1 '(c/cfunction init
            :static
              "Initializes the GLFW context, run once to setup the library.
returns false on [failure](https://www.glfw.org/docs/latest/intro_guide.html#error_handling)"
            [] -> bool
            (return (glfwInit))))

  (macex1 '(c/cfunction terminate
            :static
              "Terminates the GLFW context, run once to shutdown the context. If you need GLFW afterwards, call init again to start it back up. If init failed, this does not have to be called. [maybe a convenience script for this?](https://janet-lang.org/api/index.html#with)"
            [] -> int
            (glfwTerminate)
            (return 1)))

  (macex1 '(c/cfunction create-window
            :static
              ```Creates a window (* GLFWwindow)
hosted by the previously initialized GLFW3 context.
optionally takes a monitor (* GLFWmonitor) [to enable true fullscreen, give a monitor you retrieved here](https://www.glfw.org/docs/latest/monitor_guide.html#monitor_monitors)
and a share of a window (* GLFWwindow) [to share its context objects with](https://www.glfw.org/docs/latest/context_guide.html#context_sharing)
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
  
  (macex1 '(c/cfunction destroy-window
            :static
              "calls `void glfwDestroyWindow(window)` in order to destroy window (* GLFWWindow). Returns 1, to uh.. to report the function ran properly."
            [window:pointer] -> int
            (glfwDestroyWindow window)
            (return 1)))

  (macex1 '(c/cfunction hint-next-window
            :static
              "gives hints to the next call to create-window. [keywords to be implemented](https://www.glfw.org/docs/latest/window_guide.html#window_hints)"
            [hint:int value:int] -> int
            (glfwWindowHint hint value)
            (return 1)))

  (macex1 '(c/cfunction close-window?
               :static
     "returns whether or not the window is supposed to close "
     [window:pointer] -> :bool
     (return (glfwWindowShouldClose window))))

  (macex1 '(c/cfunction poll-events
               :static
     "polls for events"
     [] -> :bool
     (glfwPollEvents)
     (return 1)))
  
  (macex1 '(c/module-entry "jlfw"))
  (file/flush f))
(file/close f)







(comment
 (macex1 '(c/cfunction wgpu-create-instance
           :static
             "i might have to keep the descriptor around but it should be just a pointer, right?"
           [] -> :int64
             (def (desc WGPUInstanceDescriptor))
           (set desc.nextInChain NULL)
           (def (instance WGPUInstance) (wgpuCreateInstance &desc))
           (return instance)))
 
 (c/cfunction get-WGPU-Surface
              :static
    [instance:pointer window:pointer] -> :uint64
    (return (glfwGetWGPUSurface instance window)))
 ```
 // Don't forget to release the adapter and instance
 wgpuAdapterRelease(adapter);
 wgpuInstanceRelease(instance);
 

/**
 * Utility function to get a WebGPU adapter, so that
 *     WGPUAdapter adapter = requestAdapter(options);
 * is roughly equivalent to
 *     const adapter = await navigator.gpu.requestAdapter(options);
 */
WGPUAdapter requestAdapter(WGPUInstance instance, WGPURequestAdapterOptions const * options) {
	// A simple structure holding the local information shared with the
	// onAdapterRequestEnded callback.
	struct UserData {
		WGPUAdapter adapter = nullptr;
		bool requestEnded = false;
	};
	UserData userData;

	// Callback called by wgpuInstanceRequestAdapter when the request returns
	// This is a C++ lambda function, but could be any function defined in the
	// global scope. It must be non-capturing (the brackets [] are empty) so
	// that it behaves like a regular C function pointer, which is what
	// wgpuInstanceRequestAdapter expects (WebGPU being a C API). The workaround
	// is to convey what we want to capture through the pUserData pointer,
	// provided as the last argument of wgpuInstanceRequestAdapter and received
	// by the callback as its last argument.
	auto onAdapterRequestEnded = [](WGPURequestAdapterStatus status, WGPUAdapter adapter, char const * message, void * pUserData) {
		UserData& userData = *reinterpret_cast<UserData*>(pUserData);
		if (status == WGPURequestAdapterStatus_Success) {
			userData.adapter = adapter;
		} else {
			std::cout << "Could not get WebGPU adapter: " << message << std::endl;
		}
		userData.requestEnded = true;
	};

	// Call to the WebGPU request adapter procedure
	wgpuInstanceRequestAdapter(
		instance /* equivalent of navigator.gpu */,
		options,
		onAdapterRequestEnded,
		(void*)&userData
	);

	// In theory we should wait until onAdapterReady has been called, which
	// could take some time (what the 'await' keyword does in the JavaScript
	// code). In practice, we know that when the wgpuInstanceRequestAdapter()
	// function returns its callback has been called.
	assert(userData.requestEnded);

	return userData.adapter;
                                                                                             }

/**
 * Utility function to get a WebGPU device, so that
 *     WGPUAdapter device = requestDevice(adapter, options);
 * is roughly equivalent to
 *     const device = await adapter.requestDevice(descriptor);
 * It is very similar to requestAdapter
 */
WGPUDevice requestDevice(WGPUAdapter adapter, WGPUDeviceDescriptor const * descriptor) {
    struct UserData {
        WGPUDevice device = nullptr;
        bool requestEnded = false;
    };
    UserData userData;

    auto onDeviceRequestEnded = [](WGPURequestDeviceStatus status, WGPUDevice device, char const * message, void * pUserData) {
        UserData& userData = *reinterpret_cast<UserData*>(pUserData);
        if (status == WGPURequestDeviceStatus_Success) {
            userData.device = device;
        } else {
            std::cout << "Could not get WebGPU adapter: " << message << std::endl;
        }
        userData.requestEnded = true;
    };

    wgpuAdapterRequestDevice(
        adapter,
        descriptor,
        onDeviceRequestEnded,
        (void*)&userData
    );

    assert(userData.requestEnded);

    return userData.device;
                                                                                       }


```)
