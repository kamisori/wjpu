static Janet cfun_glfwInit(int32_t argc, Janet *argv) {
    (void) argv;
    janet_fixarity(argc, 0);
    return janet_wrap_boolean(glfwInit());
}

static Janet cfun_glfwTerminate(int32_t argc, Janet *argv) {
    (void) argv;
    janet_fixarity(argc, 0);
    glfwTerminate();
    return janet_wrap_nil();
}

static Janet cfun_glfwCreateWindow(int32_t argc, Janet *argv) {
    janet_fixarity(argc, 3);
    
    int32_t width = janet_getinteger(argv, 0);
    int32_t height = janet_getinteger(argv, 1);
    const char *title = janet_getcstring(argv, 2);
    
    GLFWmonitor* monitor = nullptr;
    GLFWwindow* share = nullptr;
    
    GLFWwindow* window = glfwCreateWindow(width, height, title, monitor, share);
    return janet_wrap_pointer(window);
}

static Janet cfun_glfwDestroyWindow(int32_t argc, Janet *argv) {
    (void) argv;
    janet_fixarity(argc, 0);
    glfwDestroyWindow(window);
    return janet_wrap_nil();
}
static Janet cfun_glfwWindowHint(int32_t argc, Janet *argv) {
    janet_fixarity(argc, 2);
    
    int32_t hint = janet_getinteger(argv, 0);
    int32_t value = janet_getinteger(argv, 1);
    //TODO needs keywords
    glfwWindowHint(hint, value);
    return janet_wrap_nil();
}


static Janet cfun_wgpuCreateInstance(int32_t argc, Janet *argv) {
    janet_fixarity(argc, 0);
    
    WGPUInstanceDescriptor desc = {};
	desc.nextInChain = nullptr;
	WGPUInstance instance = wgpuCreateInstance(&desc);
    
    return janet_wrap_abstract(instance);
}

static Janet cfun_glfwGetWGPUSurface(int32_t argc, Janet *argv) {
    janet_fixarity(argc, 2);
    
    WGPUInstance instance = janet_unwrap_abstract(argv, 0);
    GLFWwindow* window = janet_unwrap_pointer(argv, 1);
    
    // Utility function provided by glfw3webgpu.h
    WGPUSurface surface = glfwGetWGPUSurface(instance, window);
    
    return janet_wrap_abstract(surface);
}

static Janet cfun_RequestAdapter(int32_t argc, Janet *argv) {
    janet_fixarity(argc, 2);
    WGPUInstance instance = janet_unwrap_abstract(argv, 0);
    WGPUSurface surface = janet_unwrap_abstract(argv, 1);
	// Adapter options: we need the adapter to draw to the window's surface
	WGPURequestAdapterOptions adapterOpts = {};
	adapterOpts.nextInChain = nullptr;
	adapterOpts.compatibleSurface = surface;

	// Get the adapter, see the comments in the definition of the body of the
	// requestAdapter function above.
	WGPUAdapter adapter = requestAdapter(instance, &adapterOpts);
    return janet_wrap_abstract(adapter);
}

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

/*    
    glfwWindowShouldClose(window);

    glfwPollEvents();
*/

static Janet cfun_notimplementedyet(int32_t argc, Janet *argv) {

    // Don't forget to release the adapter
	wgpuAdapterRelease(adapter);
	wgpuInstanceRelease(instance);
}

static JanetReg glfw_cfuns[] = {
    {"init", cfun_glfwInit,
        "(init)\n\n"
        "Initialize glfw and return true if it's successful"
    },
    {"terminate", cfun_glfwTerminate,
        "(terminate)\n\n"
        "Terminate glfw"
    },
    {"create-window", cfun_glfwCreateWindow,
        "(create-window width height title)\n\n"
        "Returns a pointer to a new window."
    },
    {"destroy-window", cfun_glfwDestroyWindow,
        "(destroy-window window)\n\n"
        "Takes a pointer to a window to smash."
    },
    {"window-hint", cfun_glfwWindowHint,
     "(window-hint hint value)\n\n"
        "Set window properties."
    },
    {"get-wgpu-surface", cfun_glfwGetWGPUSurface,
     "(get-wgpu-surface instance window)\n\n"
        "Returns WGPU surface AT, takes instance of AT WGPUInstance and window pointer"
    },
    {NULL, NULL, NULL}
};

static JanetReg wgpu_cfuns[] = {
    {"create-instance", cfun_wgpuCreateInstance,
     "(create-instance)\n\n"
     "initializes wgpu instance"
    },
    {"request-adapter", cfun_RequestAdapter,
     "(request-adapter instance compatible-surface)\n\n"
     "requests an adapter for the given instance and a compatible surface"
    {NULL, NULL, NULL}
};
