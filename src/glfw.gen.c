#include "glfw.aux.h"

/* Initializes the GLFW context,
run once to setup the library.

returns false on failure
see: https://www.glfw.org/docs/latest/intro_guide.html#error_handling */
static int init() {
  return glfwInit();
}

JANET_FN(_generated_cfunction_init,
        "(init)", 
        "Initializes the GLFW context,\nrun once to setup the library.\n\nreturns false on failure\nsee: https://www.glfw.org/docs/latest/intro_guide.html#error_handling")
{
  janet_fixarity(argc, 0);
  return janet_wrap_boolean(init());
}

/* Terminates the GLFW context,
run once to shutdown the context.
If you need GLFW afterwards, call init again to start it back up.

If init failed, this does not have to be called.

---
TODO: maybe a convenience script/macro for init+terminate? https://janet-lang.org/api/index.html#with */
static int terminate() {
  glfwTerminate();
  return 1;
}

JANET_FN(_generated_cfunction_terminate,
        "(terminate)", 
        "Terminates the GLFW context,\nrun once to shutdown the context.\nIf you need GLFW afterwards, call init again to start it back up.\n\nIf init failed, this does not have to be called.\n\n---\nTODO: maybe a convenience script/macro for init+terminate? https://janet-lang.org/api/index.html#with")
{
  janet_fixarity(argc, 0);
  return janet_wrap_number(terminate());
}

/* Creates a window (* GLFWwindow)
hosted by the previously initialized GLFW3 context.

optionally takes a monitor (* GLFWmonitor)
to enable true fullscreen, give a monitor you retrieved here:
https://www.glfw.org/docs/latest/monitor_guide.html#monitor_monitors

and a share of a window (* GLFWwindow)
to share its context objects with:
https://www.glfw.org/docs/latest/context_guide.html#context_sharing

Returns a wrapped pointer to the window object inside glfwspace. */
static void * create_window(int width, int height, const char * title, void *monitor, void *share) {
  return glfwCreateWindow(width, height, title, monitor, share);
}

JANET_FN(_generated_cfunction_create_window,
        "(create-window width:int height:int title:cstring &opt (monitor :pointer NULL) (share :pointer NULL))", 
        "Creates a window (* GLFWwindow)\nhosted by the previously initialized GLFW3 context.\n\noptionally takes a monitor (* GLFWmonitor)\nto enable true fullscreen, give a monitor you retrieved here:\nhttps://www.glfw.org/docs/latest/monitor_guide.html#monitor_monitors\n\nand a share of a window (* GLFWwindow)\nto share its context objects with:\nhttps://www.glfw.org/docs/latest/context_guide.html#context_sharing\n\nReturns a wrapped pointer to the window object inside glfwspace.")
{
  janet_arity(argc, 3, 5);
  int width = janet_getinteger(argv, 0);
  int height = janet_getinteger(argv, 1);
  const char * title = janet_getcstring(argv, 2);
  void *monitor = janet_optpointer(argv, argc, 3, NULL);
  void *share = janet_optpointer(argv, argc, 4, NULL);
  return janet_wrap_pointer(create_window(width, height, title, monitor, share));
}

/* calls `void glfwDestroyWindow(window)` in order to destroy window (* GLFWWindow). Returns 1, to uh.. to report the function ran properly. */
static int destroy_window(void *window) {
  glfwDestroyWindow(window);
  return 1;
}

JANET_FN(_generated_cfunction_destroy_window,
        "(destroy-window window:pointer)", 
        "calls `void glfwDestroyWindow(window)` in order to destroy window (* GLFWWindow). Returns 1, to uh.. to report the function ran properly.")
{
  janet_fixarity(argc, 1);
  void *window = janet_getpointer(argv, 0);
  return janet_wrap_number(destroy_window(window));
}

/* gives hints to the next call to create-window. [keywords to be implemented](https://www.glfw.org/docs/latest/window_guide.html#window_hints) */
static int hint_next_window(int hint, int value) {
  glfwWindowHint(hint, value);
  return 1;
}

JANET_FN(_generated_cfunction_hint_next_window,
        "(hint-next-window hint:int value:int)", 
        "gives hints to the next call to create-window. [keywords to be implemented](https://www.glfw.org/docs/latest/window_guide.html#window_hints)")
{
  janet_fixarity(argc, 2);
  int hint = janet_getinteger(argv, 0);
  int value = janet_getinteger(argv, 1);
  return janet_wrap_number(hint_next_window(hint, value));
}

/* returns whether or not the window is supposed to close  */
static int close_window_X63(void *window) {
  return glfwWindowShouldClose(window);
}

JANET_FN(_generated_cfunction_close_window_X63,
        "(close-window? window:pointer)", 
        "returns whether or not the window is supposed to close ")
{
  janet_fixarity(argc, 1);
  void *window = janet_getpointer(argv, 0);
  return janet_wrap_boolean(close_window_X63(window));
}

/* polls for events */
static int poll_events() {
  glfwPollEvents();
  return 1;
}

JANET_FN(_generated_cfunction_poll_events,
        "(poll-events)", 
        "polls for events")
{
  janet_fixarity(argc, 0);
  return janet_wrap_boolean(poll_events());
}

/* returns a new wgpu instance which needs to be released/dropped via wgpu-destroy-instance */
static void * wgpu_create_instance() {
  WGPUInstanceDescriptor desc;
  desc.nextInChain = NULL;
  WGPUInstance* instance = janet_smalloc(sizeof(WGPUInstance));
  *instance = (wgpuCreateInstance(&desc));
  return instance;
}

JANET_FN(_generated_cfunction_wgpu_create_instance,
        "(wgpu-create-instance)", 
        "returns a new wgpu instance which needs to be released/dropped via wgpu-destroy-instance")
{
  janet_fixarity(argc, 0);
  return janet_wrap_pointer(wgpu_create_instance());
}

/* frees the reserved mem for the instance handle and releases or drops the instance */
static int wgpu_destroy_instance(void *instance) {
  WGPUInstance* tmp = (WGPUInstance*)instance;
  wgpuInstanceRelease(*tmp);
  janet_sfree(tmp);
  return 1;
}

JANET_FN(_generated_cfunction_wgpu_destroy_instance,
        "(wgpu-destroy-instance instance:pointer)", 
        "frees the reserved mem for the instance handle and releases or drops the instance")
{
  janet_fixarity(argc, 1);
  void *instance = janet_getpointer(argv, 0);
  return janet_wrap_number(wgpu_destroy_instance(instance));
}

/* using a WGPUInstance and GLFWwindow to create a WGPUSurface which needs to be released/dropped via wgpu-destroy-surface */
static void * wgpu_create_surface(void *instance, void *window) {
  WGPUInstance* tmpi = (WGPUInstance*)instance;
  GLFWwindow* tmpw = (GLFWwindow*)window;
  WGPUSurface* surface = janet_smalloc(sizeof(WGPUSurface));
  *surface = (glfwGetWGPUSurface(*tmpi, tmpw));
  return surface;
}

JANET_FN(_generated_cfunction_wgpu_create_surface,
        "(wgpu-create-surface instance:pointer window:pointer)", 
        "using a WGPUInstance and GLFWwindow to create a WGPUSurface which needs to be released/dropped via wgpu-destroy-surface")
{
  janet_fixarity(argc, 2);
  void *instance = janet_getpointer(argv, 0);
  void *window = janet_getpointer(argv, 1);
  return janet_wrap_pointer(wgpu_create_surface(instance, window));
}

/* frees the reserved mem for the surface handle and releases or drops the surface */
static int wgpu_destroy_surface(void *surface) {
  WGPUSurface* tmp = (WGPUSurface*)surface;
  wgpuSurfaceRelease(*tmp);
  janet_sfree(tmp);
  return 1;
}

JANET_FN(_generated_cfunction_wgpu_destroy_surface,
        "(wgpu-destroy-surface surface:pointer)", 
        "frees the reserved mem for the surface handle and releases or drops the surface")
{
  janet_fixarity(argc, 1);
  void *surface = janet_getpointer(argv, 0);
  return janet_wrap_number(wgpu_destroy_surface(surface));
}

/* using a WGPUInstance and WGPUSurface to create a WGPUAdapter which needs to be released/dropped via wgpu-destroy-adapter */
static void * wgpu_create_adapter(void *instance, void *surface) {
  WGPUInstance* tmpi = (WGPUInstance*)instance;
  WGPUSurface* tmps = (WGPUSurface*)surface;
  WGPURequestAdapterOptions adapterOptions;
  adapterOptions.nextInChain = NULL;
  adapterOptions.compatibleSurface = (*tmps);
  WGPUAdapter* adapter = requestAdapter_smalloc(*tmpi, &adapterOptions);
  return adapter;
}

JANET_FN(_generated_cfunction_wgpu_create_adapter,
        "(wgpu-create-adapter instance:pointer surface:pointer)", 
        "using a WGPUInstance and WGPUSurface to create a WGPUAdapter which needs to be released/dropped via wgpu-destroy-adapter")
{
  janet_fixarity(argc, 2);
  void *instance = janet_getpointer(argv, 0);
  void *surface = janet_getpointer(argv, 1);
  return janet_wrap_pointer(wgpu_create_adapter(instance, surface));
}

/* frees the reserved mem for the adapter handle and releases or drops the adapter */
static int wgpu_destroy_adapter(void *adapter) {
  WGPUAdapter* tmp = (WGPUAdapter*)adapter;
  wgpuAdapterRelease(*tmp);
  janet_sfree(tmp);
  return 1;
}

JANET_FN(_generated_cfunction_wgpu_destroy_adapter,
        "(wgpu-destroy-adapter adapter:pointer)", 
        "frees the reserved mem for the adapter handle and releases or drops the adapter")
{
  janet_fixarity(argc, 1);
  void *adapter = janet_getpointer(argv, 0);
  return janet_wrap_number(wgpu_destroy_adapter(adapter));
}

/* prints information about the adapter */
static int wgpu_inspect_adapter(void *adapter) {
  WGPUAdapter* tmpa = (WGPUAdapter*)adapter;
  size_t featureCount = wgpuAdapterEnumerateFeatures(*tmpa, NULL);
  WGPUFeatureName* features = janet_smalloc(featureCount * (sizeof(WGPUFeatureName)));
  wgpuAdapterEnumerateFeatures(*tmpa, features);
  printf("Adapter features:\n");
  int i;
  for (i=0; i <= featureCount; ++i)   {
    switch (features[i]) {
      case WGPUFeatureName_Undefined:
      {
        printf("    Undefined\n");
        break;
      }

      case WGPUFeatureName_DepthClipControl:
      {
        printf("    DepthClipControl\n");
        break;
      }

      case WGPUFeatureName_Depth32FloatStencil8:
      {
        printf("    Depth32FloatStencil8\n");
        break;
      }

      case WGPUFeatureName_TimestampQuery:
      {
        printf("    TimestampQuery\n");
        break;
      }

      case WGPUFeatureName_PipelineStatisticsQuery:
      {
        printf("    PipelineStatisticsQuery\n");
        break;
      }

      case WGPUFeatureName_TextureCompressionBC:
      {
        printf("    TextureCompressionBC\n");
        break;
      }

      case WGPUFeatureName_TextureCompressionETC2:
      {
        printf("    TextureCompressionETC2\n");
        break;
      }

      case WGPUFeatureName_TextureCompressionASTC:
      {
        printf("    TextureCompressionASTC\n");
        break;
      }

      case WGPUFeatureName_IndirectFirstInstance:
      {
        printf("    IndirectFirstInstance\n");
        break;
      }

      case WGPUFeatureName_ShaderF16:
      {
        printf("    ShaderF16\n");
        break;
      }

      case WGPUFeatureName_RG11B10UfloatRenderable:
      {
        printf("    RG11B10UfloatRenderable\n");
        break;
      }

      case WGPUFeatureName_BGRA8UnormStorage:
      {
        printf("    BGRA8UnormStorage\n");
        break;
      }

      case WGPUFeatureName_Force32:
      {
        printf("    Force32\n");
        break;
      }

      default:
      printf("    unknown: %d\n", features[i]);

    }
  }

  janet_sfree(features);
  return featureCount;
}

JANET_FN(_generated_cfunction_wgpu_inspect_adapter,
        "(wgpu-inspect-adapter adapter:pointer)", 
        "prints information about the adapter")
{
  janet_fixarity(argc, 1);
  void *adapter = janet_getpointer(argv, 0);
  return janet_wrap_number(wgpu_inspect_adapter(adapter));
}

/* using a WGPUAdapter to create a WGPUDevice which needs to be released/dropped via wgpu-destroy-device */
static void * wgpu_create_device(void *adapter) {
  WGPUAdapter* tmpa = (WGPUAdapter*)adapter;
  WGPUDeviceDescriptor deviceDescriptor;
  deviceDescriptor.nextInChain = NULL;
  deviceDescriptor.label = "My Device";
  deviceDescriptor.requiredFeaturesCount = 0;
  deviceDescriptor.requiredLimits = NULL;
  deviceDescriptor.defaultQueue.nextInChain = NULL;
  deviceDescriptor.defaultQueue.label = "The default queue.";
  WGPUDevice* device = requestDevice(*tmpa, &deviceDescriptor);
  return device;
}

JANET_FN(_generated_cfunction_wgpu_create_device,
        "(wgpu-create-device adapter:pointer)", 
        "using a WGPUAdapter to create a WGPUDevice which needs to be released/dropped via wgpu-destroy-device")
{
  janet_fixarity(argc, 1);
  void *adapter = janet_getpointer(argv, 0);
  return janet_wrap_pointer(wgpu_create_device(adapter));
}

/* frees the reserved mem for the device handle and releases or drops the device */
static int wgpu_destroy_device(void *device) {
  WGPUDevice* tmp = (WGPUDevice*)device;
  wgpuDeviceRelease(*tmp);
  janet_sfree(tmp);
  return 1;
}

JANET_FN(_generated_cfunction_wgpu_destroy_device,
        "(wgpu-destroy-device device:pointer)", 
        "frees the reserved mem for the device handle and releases or drops the device")
{
  janet_fixarity(argc, 1);
  void *device = janet_getpointer(argv, 0);
  return janet_wrap_number(wgpu_destroy_device(device));
}

/* callback for when the device encounters an error */
int onDeviceError_callback(WGPUErrorType type, const char* message, void* pUserData) {
  fprintf(stderr, "Uncaptured device error: type %d", type);
  if (message) {
    fprintf(stderr, message);
  }
  return 1;
}

/* gives wgpu a callback to call whenever the device encounters an error.     will print type and message, but could receive a void pointer, which wouldnt be touched currently.     open for suggestions for how to best exploit this for debugging <3 */
static int wgpu_device_set_uncaptured_error_callback(void *device) {
  WGPUDevice* tmp = (WGPUDevice*)device;
  void* pUserData = NULL;
  wgpuDeviceSetUncapturedErrorCallback(*tmp, onDeviceError_callback, pUserData);
  return 1;
}

JANET_FN(_generated_cfunction_wgpu_device_set_uncaptured_error_callback,
        "(wgpu-device-set-uncaptured-error-callback device:pointer)", 
        "gives wgpu a callback to call whenever the device encounters an error.     will print type and message, but could receive a void pointer, which wouldnt be touched currently.     open for suggestions for how to best exploit this for debugging <3")
{
  janet_fixarity(argc, 1);
  void *device = janet_getpointer(argv, 0);
  return janet_wrap_number(wgpu_device_set_uncaptured_error_callback(device));
}

/*  */
static void * wgpu_device_create_queue(void *device) {
  WGPUDevice* tmpd = (WGPUDevice*)device;
  WGPUQueue* queue = janet_smalloc(sizeof(WGPUQueue));
  *queue = (wgpuDeviceGetQueue(*tmpd));
  return queue;
}

JANET_FN(_generated_cfunction_wgpu_device_create_queue,
        "(wgpu-device-create-queue device:pointer)", 
        "")
{
  janet_fixarity(argc, 1);
  void *device = janet_getpointer(argv, 0);
  return janet_wrap_pointer(wgpu_device_create_queue(device));
}

/* frees the reserved mem for the queue handle and releases or drops the queue */
static int wgpu_destroy_queue(void *queue) {
  WGPUQueue* tmp = (WGPUQueue*)queue;
  janet_sfree(tmp);
  return 1;
}

JANET_FN(_generated_cfunction_wgpu_destroy_queue,
        "(wgpu-destroy-queue queue:pointer)", 
        "frees the reserved mem for the queue handle and releases or drops the queue")
{
  janet_fixarity(argc, 1);
  void *queue = janet_getpointer(argv, 0);
  return janet_wrap_number(wgpu_destroy_queue(queue));
}

/*  */
static void * wgpu_device_create_swapchain(void *device, void *adapter, void *surface) {
  WGPUDevice* tmpd = (WGPUDevice*)device;
  WGPUAdapter* tmpa = (WGPUAdapter*)adapter;
  WGPUSurface* tmps = (WGPUSurface*)surface;
  WGPUSwapChainDescriptor swapChainDesc;
  swapChainDesc.nextInChain = NULL;
  swapChainDesc.width = 640;
  swapChainDesc.height = 480;
  swapChainDesc.format = (wgpuSurfaceGetPreferredFormat(*tmps, *tmpa));
  swapChainDesc.usage = WGPUTextureUsage_RenderAttachment;
  swapChainDesc.presentMode = WGPUPresentMode_Fifo;
  WGPUSwapChain* result = janet_smalloc(sizeof(WGPUSwapChain));
  *result = (wgpuDeviceCreateSwapChain(*tmpd, *tmps, &swapChainDesc));
  return result;
}

JANET_FN(_generated_cfunction_wgpu_device_create_swapchain,
        "(wgpu-device-create-swapchain device:pointer adapter:pointer surface:pointer)", 
        "")
{
  janet_fixarity(argc, 3);
  void *device = janet_getpointer(argv, 0);
  void *adapter = janet_getpointer(argv, 1);
  void *surface = janet_getpointer(argv, 2);
  return janet_wrap_pointer(wgpu_device_create_swapchain(device, adapter, surface));
}

/* frees the reserved mem for the swapchain handle and releases or drops the swapchain */
static int wgpu_destroy_swapchain(void *swapChain) {
  WGPUSwapChain* tmp = (WGPUSwapChain*)swapChain;
  wgpuSwapChainRelease(*tmp);
  janet_sfree(tmp);
  return 1;
}

JANET_FN(_generated_cfunction_wgpu_destroy_swapchain,
        "(wgpu-destroy-swapchain swapChain:pointer)", 
        "frees the reserved mem for the swapchain handle and releases or drops the swapchain")
{
  janet_fixarity(argc, 1);
  void *swapChain = janet_getpointer(argv, 0);
  return janet_wrap_number(wgpu_destroy_swapchain(swapChain));
}

/*  */
static int wgpu_swapchain_present(void *swapChain) {
  WGPUSwapChain* tmp = (WGPUSwapChain*)swapChain;
  wgpuSwapChainPresent(*tmp);
  return 1;
}

JANET_FN(_generated_cfunction_wgpu_swapchain_present,
        "(wgpu-swapchain-present swapChain:pointer)", 
        "")
{
  janet_fixarity(argc, 1);
  void *swapChain = janet_getpointer(argv, 0);
  return janet_wrap_number(wgpu_swapchain_present(swapChain));
}

/*  */
static void * wgpu_swapchain_create_next_textureview(void *swapChain) {
  WGPUSwapChain* tmps = (WGPUSwapChain*)swapChain;
  WGPUTextureView* result = janet_smalloc(sizeof(WGPUTextureView));
  *result = (wgpuSwapChainGetCurrentTextureView(*tmps));
  if (!result) {
    {
      janet_sfree(result);
      return NULL;
    }
  } else {
    return result;
  }
}

JANET_FN(_generated_cfunction_wgpu_swapchain_create_next_textureview,
        "(wgpu-swapchain-create-next-textureview swapChain:pointer)", 
        "")
{
  janet_fixarity(argc, 1);
  void *swapChain = janet_getpointer(argv, 0);
  return janet_wrap_pointer(wgpu_swapchain_create_next_textureview(swapChain));
}

/* frees the reserved mem for the swapchain handle and releases or drops the swapchain */
static int wgpu_destroy_textureview(void *textureview) {
  if (!textureview) {
    {
      WGPUTextureView* tmp = (WGPUTextureView*)textureview;
      wgpuTextureViewRelease(*tmp);
      janet_sfree(tmp);
      return 1;
    }
  } else {
    return 0;
  }
}

JANET_FN(_generated_cfunction_wgpu_destroy_textureview,
        "(wgpu-destroy-textureview textureview:pointer)", 
        "frees the reserved mem for the swapchain handle and releases or drops the swapchain")
{
  janet_fixarity(argc, 1);
  void *textureview = janet_getpointer(argv, 0);
  return janet_wrap_number(wgpu_destroy_textureview(textureview));
}

/*  */
static void * wgpu_get_example_renderpass(void *encoder, void *nextTexture) {
  WGPUCommandEncoder* tmpe = (WGPUCommandEncoder*)encoder;
  WGPUTextureView* tmpt = (WGPUTextureView*)nextTexture;
  WGPURenderPassColorAttachment renderPassColorAttachment;
  renderPassColorAttachment.view = *tmpt;
  renderPassColorAttachment.resolveTarget = NULL;
  renderPassColorAttachment.loadOp = WGPULoadOp_Clear;
  renderPassColorAttachment.storeOp = WGPUStoreOp_Store;
  WGPUColor color;
  color.r = 0.90000000000000002;
  color.g = 0.10000000000000001;
  color.b = 0.20000000000000001;
  color.a = 1;
  renderPassColorAttachment.clearValue = color;
  WGPURenderPassDescriptor renderPassDesc;
  renderPassDesc.colorAttachmentCount = 1;
  renderPassDesc.colorAttachments = &renderPassColorAttachment;
  renderPassDesc.depthStencilAttachment = NULL;
  renderPassDesc.timestampWriteCount = 0;
  renderPassDesc.timestampWrites = NULL;
  renderPassDesc.nextInChain = NULL;
  WGPURenderPassEncoder* renderPass = janet_smalloc(sizeof(WGPURenderPassEncoder));
  *renderPass = (wgpuCommandEncoderBeginRenderPass(*tmpe, &renderPassDesc));
  return renderPass;
}

JANET_FN(_generated_cfunction_wgpu_get_example_renderpass,
        "(wgpu-get-example-renderpass encoder:pointer nextTexture:pointer)", 
        "")
{
  janet_fixarity(argc, 2);
  void *encoder = janet_getpointer(argv, 0);
  void *nextTexture = janet_getpointer(argv, 1);
  return janet_wrap_pointer(wgpu_get_example_renderpass(encoder, nextTexture));
}

/* frees the reserved mem for the swapchain handle and releases or drops the swapchain */
static int wgpu_render_pass_encoder_end(void *renderPass) {
  WGPURenderPassEncoder* tmp = (WGPURenderPassEncoder*)renderPass;
  wgpuRenderPassEncoderEnd(*tmp);
  return 1;
}

JANET_FN(_generated_cfunction_wgpu_render_pass_encoder_end,
        "(wgpu-render-pass-encoder-end renderPass:pointer)", 
        "frees the reserved mem for the swapchain handle and releases or drops the swapchain")
{
  janet_fixarity(argc, 1);
  void *renderPass = janet_getpointer(argv, 0);
  return janet_wrap_number(wgpu_render_pass_encoder_end(renderPass));
}

/*  */
static void * wgpu_device_get_command_encoder(void *device) {
  WGPUDevice* tmpd = (WGPUDevice*)device;
  WGPUCommandEncoderDescriptor encoderDesc;
  encoderDesc.nextInChain = NULL;
  encoderDesc.label = "My command encoder";
  WGPUCommandEncoder* result = janet_smalloc(sizeof(WGPUCommandEncoder));
  *result = (wgpuDeviceCreateCommandEncoder(*tmpd, &encoderDesc));
  return result;
}

JANET_FN(_generated_cfunction_wgpu_device_get_command_encoder,
        "(wgpu-device-get-command-encoder device:pointer)", 
        "")
{
  janet_fixarity(argc, 1);
  void *device = janet_getpointer(argv, 0);
  return janet_wrap_pointer(wgpu_device_get_command_encoder(device));
}

/*  */
static int wgpu_command_encoder_insert_debug_marker(void *encoder, JanetString marker) {
  WGPUCommandEncoder* tmpe = (WGPUCommandEncoder*)encoder;
  wgpuCommandEncoderInsertDebugMarker(*tmpe, marker);
  return 1;
}

JANET_FN(_generated_cfunction_wgpu_command_encoder_insert_debug_marker,
        "(wgpu-command-encoder-insert-debug-marker encoder:pointer marker:string)", 
        "")
{
  janet_fixarity(argc, 2);
  void *encoder = janet_getpointer(argv, 0);
  JanetString marker = janet_getstring(argv, 1);
  return janet_wrap_number(wgpu_command_encoder_insert_debug_marker(encoder, marker));
}

/* allocates a pointer for the commandbuffer can be reused each frame */
static void * create_command_buffer() {
  return janet_smalloc(sizeof(WGPUCommandBuffer));
}

JANET_FN(_generated_cfunction_create_command_buffer,
        "(create-command-buffer)", 
        "allocates a pointer for the commandbuffer can be reused each frame")
{
  janet_fixarity(argc, 0);
  return janet_wrap_pointer(create_command_buffer());
}

/* consumes encoder, do not touch afterwards */
static int wgpu_command_encoder_finish_ref(void *encoder, void *cmdbuffer) {
  WGPUCommandEncoder* tmpe = (WGPUCommandEncoder*)encoder;
  WGPUCommandBuffer* tmpc = (WGPUCommandBuffer*)cmdbuffer;
  WGPUCommandBufferDescriptor cmdBufferDescriptor;
  cmdBufferDescriptor.nextInChain = NULL;
  cmdBufferDescriptor.label = "Command buffer";
  *tmpc = (wgpuCommandEncoderFinish(*tmpe, &cmdBufferDescriptor));
  return 1;
}

JANET_FN(_generated_cfunction_wgpu_command_encoder_finish_ref,
        "(wgpu-command-encoder-finish-ref encoder:pointer cmdbuffer:pointer)", 
        "consumes encoder, do not touch afterwards")
{
  janet_fixarity(argc, 2);
  void *encoder = janet_getpointer(argv, 0);
  void *cmdbuffer = janet_getpointer(argv, 1);
  return janet_wrap_number(wgpu_command_encoder_finish_ref(encoder, cmdbuffer));
}

/* frees the reserved mem for the commandbuffer handle */
static int destroy_command_buffer(void *commandbuffer) {
  WGPUCommandBuffer* tmp = (WGPUCommandBuffer*)commandbuffer;
  janet_sfree(tmp);
  return 1;
}

JANET_FN(_generated_cfunction_destroy_command_buffer,
        "(destroy-command-buffer commandbuffer:pointer)", 
        "frees the reserved mem for the commandbuffer handle")
{
  janet_fixarity(argc, 1);
  void *commandbuffer = janet_getpointer(argv, 0);
  return janet_wrap_number(destroy_command_buffer(commandbuffer));
}

/*  */
static int wgpu_queue_submit(void *queue, int commands, void *commandbuffer) {
  WGPUQueue* tmpq = (WGPUQueue*)queue;
  WGPUCommandBuffer* tmpc = (WGPUCommandBuffer*)commandbuffer;
  wgpuQueueSubmit(*tmpq, commands, tmpc);
  return 1;
}

JANET_FN(_generated_cfunction_wgpu_queue_submit,
        "(wgpu-queue-submit queue:pointer commands:int commandbuffer:pointer)", 
        "")
{
  janet_fixarity(argc, 3);
  void *queue = janet_getpointer(argv, 0);
  int commands = janet_getinteger(argv, 1);
  void *commandbuffer = janet_getpointer(argv, 2);
  return janet_wrap_number(wgpu_queue_submit(queue, commands, commandbuffer));
}

/*  */
static void * wgpu_surface_create_preferred_format(void *surface, void *adapter) {
  WGPUAdapter* tmpa = (WGPUAdapter*)adapter;
  WGPUSurface* tmps = (WGPUSurface*)surface;
  WGPUTextureFormat* result = janet_smalloc(sizeof(WGPUTextureFormat));
  *result = (wgpuSurfaceGetPreferredFormat(*tmps, *tmpa));
  return result;
}

JANET_FN(_generated_cfunction_wgpu_surface_create_preferred_format,
        "(wgpu-surface-create-preferred-format surface:pointer adapter:pointer)", 
        "")
{
  janet_fixarity(argc, 2);
  void *surface = janet_getpointer(argv, 0);
  void *adapter = janet_getpointer(argv, 1);
  return janet_wrap_pointer(wgpu_surface_create_preferred_format(surface, adapter));
}

/* frees the reserved mem for the preferred-format handle and releases or drops the preferred-format */
static int wgpu_destroy_preferred_format(void *preferredformat) {
  WGPUTextureFormat* tmp = (WGPUTextureFormat*)preferredformat;
  janet_sfree(tmp);
  return 1;
}

JANET_FN(_generated_cfunction_wgpu_destroy_preferred_format,
        "(wgpu-destroy-preferred-format preferredformat:pointer)", 
        "frees the reserved mem for the preferred-format handle and releases or drops the preferred-format")
{
  janet_fixarity(argc, 1);
  void *preferredformat = janet_getpointer(argv, 0);
  return janet_wrap_number(wgpu_destroy_preferred_format(preferredformat));
}

JANET_MODULE_ENTRY(JanetTable *env) {
  JanetRegExt cfuns[] = {
    JANET_REG("init", _generated_cfunction_init), 
    JANET_REG("terminate", _generated_cfunction_terminate), 
    JANET_REG("create-window", _generated_cfunction_create_window), 
    JANET_REG("destroy-window", _generated_cfunction_destroy_window), 
    JANET_REG("hint-next-window", _generated_cfunction_hint_next_window), 
    JANET_REG("close-window?", _generated_cfunction_close_window_X63), 
    JANET_REG("poll-events", _generated_cfunction_poll_events), 
    JANET_REG("wgpu-create-instance", _generated_cfunction_wgpu_create_instance), 
    JANET_REG("wgpu-destroy-instance", _generated_cfunction_wgpu_destroy_instance), 
    JANET_REG("wgpu-create-surface", _generated_cfunction_wgpu_create_surface), 
    JANET_REG("wgpu-destroy-surface", _generated_cfunction_wgpu_destroy_surface), 
    JANET_REG("wgpu-create-adapter", _generated_cfunction_wgpu_create_adapter), 
    JANET_REG("wgpu-destroy-adapter", _generated_cfunction_wgpu_destroy_adapter), 
    JANET_REG("wgpu-inspect-adapter", _generated_cfunction_wgpu_inspect_adapter), 
    JANET_REG("wgpu-create-device", _generated_cfunction_wgpu_create_device), 
    JANET_REG("wgpu-destroy-device", _generated_cfunction_wgpu_destroy_device), 
    JANET_REG("wgpu-device-set-uncaptured-error-callback", _generated_cfunction_wgpu_device_set_uncaptured_error_callback), 
    JANET_REG("wgpu-device-create-queue", _generated_cfunction_wgpu_device_create_queue), 
    JANET_REG("wgpu-destroy-queue", _generated_cfunction_wgpu_destroy_queue), 
    JANET_REG("wgpu-device-create-swapchain", _generated_cfunction_wgpu_device_create_swapchain), 
    JANET_REG("wgpu-destroy-swapchain", _generated_cfunction_wgpu_destroy_swapchain), 
    JANET_REG("wgpu-swapchain-present", _generated_cfunction_wgpu_swapchain_present), 
    JANET_REG("wgpu-swapchain-create-next-textureview", _generated_cfunction_wgpu_swapchain_create_next_textureview), 
    JANET_REG("wgpu-destroy-textureview", _generated_cfunction_wgpu_destroy_textureview), 
    JANET_REG("wgpu-get-example-renderpass", _generated_cfunction_wgpu_get_example_renderpass), 
    JANET_REG("wgpu-render-pass-encoder-end", _generated_cfunction_wgpu_render_pass_encoder_end), 
    JANET_REG("wgpu-device-get-command-encoder", _generated_cfunction_wgpu_device_get_command_encoder), 
    JANET_REG("wgpu-command-encoder-insert-debug-marker", _generated_cfunction_wgpu_command_encoder_insert_debug_marker), 
    JANET_REG("create-command-buffer", _generated_cfunction_create_command_buffer), 
    JANET_REG("wgpu-command-encoder-finish-ref", _generated_cfunction_wgpu_command_encoder_finish_ref), 
    JANET_REG("destroy-command-buffer", _generated_cfunction_destroy_command_buffer), 
    JANET_REG("wgpu-queue-submit", _generated_cfunction_wgpu_queue_submit), 
    JANET_REG("wgpu-surface-create-preferred-format", _generated_cfunction_wgpu_surface_create_preferred_format), 
    JANET_REG("wgpu-destroy-preferred-format", _generated_cfunction_wgpu_destroy_preferred_format), 
    JANET_REG_END
  };
  janet_cfuns_ext(env, "wjpu", cfuns);
}
