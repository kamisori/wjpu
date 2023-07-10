#include <janet.h>
#include <tarray.h>
#include <GLFW/glfw3.h>
#include <webgpu/webgpu.h>
#include <webgpu/webgpu-release.h>
#include <glfw3webgpu.hpp>

template <typename T>
T unwrap_wgpu(Janet wgpuHandle) {
  return (T)(janet_unwrap_u64(wgpuHandle));
}

template <typename T>
Janet wrap_wgpu(T wgpuHandle) {
  return janet_wrap_u64((uint64_t)wgpuHandle);
}


// A simple structure holding information shared with the
// onAdapterRequestEnded or onDeviceRequestEnded callback.
template <class T>
class WGPURequestBackEnvelope {
private:
  bool requestEnd = false;
  T payload;
public:
  void requestEnded() { this->requestEnd = true; }
  bool hasRequestEndedQ() { return this->requestEnd; }
  void setPayload(T t) { this->payload = t; }

  Janet getPayloadSync(const char* payloadName)
  {
    int64_t i = -1;
    if(!this->hasRequestEndedQ()){
      int64_t i = 0;
      while(!this->hasRequestEndedQ() && i < 100000)
      {
        i++;
      }
    }
    if(this->hasRequestEndedQ()){
      if(i != -1){
#ifdef WJPU_C99_FORMAT
        printf("Got %s after %Id cycles\n", payloadName, i);
#elif WJPU_ANSI_C_FORMAT
        printf("Got %s after %ld cycles\n", payloadName, i);
#else
        printf("Got %s after a while.\n", payloadName);
#endif
      }
    }
    else
    {
#ifdef WJPU_C99_FORMAT
      fprintf(stderr, "Timeout: No %s after (%Id) cycles\n", payloadName, i);
#elif WJPU_ANSI_C_FORMAT
      fprintf(stderr, "Timeout: No %s after (%ld) cycles\n", payloadName, i);
#else
      fprintf(stderr, "Timeout: No %s.\n", payloadName, i);
#endif
      return janet_wrap_nil();
    }
    return wrap_wgpu<T>(this->payload);
  }

  WGPURequestBackEnvelope(){}
};


// Callback called by wgpuInstanceRequestAdapter when the request returns
// regular C function to become a pointer, which is what
// wgpuInstanceRequestAdapter expects (WebGPU being a C API).
void onAdapterRequestEnded_callback(WGPURequestAdapterStatus status,
                                    WGPUAdapter adapter,
                                    char const * message,
                                    void * pUserData) {
  WGPURequestBackEnvelope<WGPUAdapter> *userData = (WGPURequestBackEnvelope<WGPUAdapter>*)(pUserData);

  if (status == WGPURequestAdapterStatus_Success) {
    userData->setPayload(adapter);
  }
  else {
    fprintf(stderr, "Could not get WebGPU adapter: ");
    fprintf(stderr, "%s", message);
  }

  userData->requestEnded();
}


void onDeviceRequestEnded_callback(WGPURequestDeviceStatus status,
                                   WGPUDevice device,
                                   char const * message,
                                   void * pUserData) {
  WGPURequestBackEnvelope<WGPUDevice> *userData = (WGPURequestBackEnvelope<WGPUDevice>*)(pUserData);

  if (status == WGPURequestDeviceStatus_Success) {
    userData->setPayload(device);
  } else {
    fprintf(stderr, "Could not get WebGPU device: ");
    fprintf(stderr, "%s", message);
  }

  userData->requestEnded();
}

/**
 * Utility function to get a WebGPU adapter, so that
 *     WGPUAdapter adapter = requestAdapter(options);
 * is roughly equivalent to
 *     const adapter = await navigator.gpu.requestAdapter(options);
 */
Janet requestAdapter(WGPUInstance instance,
                      WGPURequestAdapterOptions const * options) {
  WGPURequestBackEnvelope<WGPUAdapter> uD;

  // Call to the WebGPU request adapter procedure
  wgpuInstanceRequestAdapter(
    instance /* equivalent of navigator.gpu */,
    options,
    onAdapterRequestEnded_callback, 
    (void*)&uD
  );

  return uD.getPayloadSync("adapter");
}



/**
 * Utility function to get a WebGPU device, so that
 *     WGPUAdapter device = requestDevice(adapter, options);
 * is roughly equivalent to
 *     const device = await adapter.requestDevice(descriptor);
 * It is very similar to requestAdapter
 */
Janet requestDevice(WGPUAdapter adapter,
                    WGPUDeviceDescriptor const * descriptor) {
  WGPURequestBackEnvelope<WGPUDevice> uD;

  wgpuAdapterRequestDevice(
    adapter,
    descriptor,
    onDeviceRequestEnded_callback,
    (void*)&uD
  );
 
  return uD.getPayloadSync("device");
}
