#include <janet.h>
#include <GLFW/glfw3.h>
#include <webgpu/webgpu.h>
#include <webgpu/webgpu-release.h>
#include <glfw3webgpu.h>

// A simple structure holding information shared with the
// onAdapterRequestEnded or onDeviceRequestEnded callback.
typedef struct {
  bool requestEnded;
  union{
    WGPUAdapter adapter;
    WGPUDevice device;
  };
} UserData;


// Callback called by wgpuInstanceRequestAdapter when the request returns
// regular C function to become a pointer, which is what
// wgpuInstanceRequestAdapter expects (WebGPU being a C API).
void onAdapterRequestEnded_callback(WGPURequestAdapterStatus status,
                                    WGPUAdapter adapter,
                                    char const * message,
                                    void * pUserData) {
  UserData *userData = (UserData*)(pUserData);

  if (status == WGPURequestAdapterStatus_Success) {
    userData->adapter = adapter;
  }
  else {
    fprintf(stderr, "Could not get WebGPU adapter: ");
    fprintf(stderr, message);
  }

  userData->requestEnded = true;
}

/**
 * Utility function to get a WebGPU adapter, so that
 *     WGPUAdapter adapter = requestAdapter(options);
 * is roughly equivalent to
 *     const adapter = await navigator.gpu.requestAdapter(options);
 */
WGPUAdapter *requestAdapter_smalloc(WGPUInstance instance,
                                    WGPURequestAdapterOptions const * options) {
  WGPUAdapter *result = NULL;
  UserData userData;
  userData.adapter = NULL;
  userData.requestEnded = false;

  // Call to the WebGPU request adapter procedure
  wgpuInstanceRequestAdapter(
    instance /* equivalent of navigator.gpu */,
    options,
    onAdapterRequestEnded_callback, 
    (void*)&userData
  );

  int64_t i = -1;
  if(!userData.requestEnded){
    int64_t i = 0;
    while(!userData.requestEnded && i < 100000)
    {
      i++;
    }
  }

  if(userData.requestEnded){
    if(i != -1)
      printf("Got adapter after %I64d cycles\n", i);
    result = janet_smalloc(sizeof(WGPUAdapter));
    *result = userData.adapter;
  }
  else
  {
    fprintf(stderr, "Timeout: No device after (%I64d) cycles\n", i);
  }
  return result;
}

void onDeviceRequestEnded_callback(WGPURequestDeviceStatus status,
                                   WGPUDevice device,
                                   char const * message,
                                   void * pUserData) {
  UserData *userData = (UserData*)(pUserData);

  if (status == WGPURequestDeviceStatus_Success) {
    userData->device = device;
  } else {
    fprintf(stderr, "Could not get WebGPU device: ");
    fprintf(stderr, message);
  }

  userData->requestEnded = true;
}


/**
 * Utility function to get a WebGPU device, so that
 *     WGPUAdapter device = requestDevice(adapter, options);
 * is roughly equivalent to
 *     const device = await adapter.requestDevice(descriptor);
 * It is very similar to requestAdapter
 */
WGPUDevice *requestDevice_smalloc(WGPUAdapter adapter,
                                  WGPUDeviceDescriptor const * descriptor) {
  WGPUDevice *result = NULL;
  UserData userData;
  userData.device = NULL;
  userData.requestEnded = false;

  wgpuAdapterRequestDevice(
    adapter,
    descriptor,
    onDeviceRequestEnded_callback,
    (void*)&userData
  );
  
  int64_t i = -1;
  if(!userData.requestEnded){
    int64_t i = 0;
    while(!userData.requestEnded && i < 100000)
    {
      i++;
    }
  }

  if(userData.requestEnded){
    if(i != -1)
      printf("Got device after %I64d cycles\n", i);
    result = janet_smalloc(sizeof(WGPUDevice));
    *result = userData.device;
  }
  else
  {
    fprintf(stderr, "Timeout: No device after (%I64d) cycles\n", i);
  }
  return result;
}
