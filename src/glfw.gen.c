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
static int inspect_wgpu_adapter(void *adapter) {
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

JANET_FN(_generated_cfunction_inspect_wgpu_adapter,
        "(inspect-wgpu-adapter adapter:pointer)", 
        "prints information about the adapter")
{
  janet_fixarity(argc, 1);
  void *adapter = janet_getpointer(argv, 0);
  return janet_wrap_number(inspect_wgpu_adapter(adapter));
}

/* using a WGPUAdapter to create a WGPUDevice which needs to be released/dropped via wgpu-destroy-device */
static void * wgpu_create_device(void *adapter) {
  WGPUAdapter* tmpa = (WGPUAdapter*)adapter;
  WGPUDeviceDescriptor desc;
  desc.nextInChain = NULL;
  desc.label = "My Device";
  desc.requiredFeaturesCount = 0;
  desc.requiredLimits = NULL;
  desc.defaultQueue.nextInChain = NULL;
  desc.defaultQueue.label = "The default queue.";
  WGPUDevice* device = requestDevice(*tmpa, &desc);
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
    JANET_REG("inspect-wgpu-adapter", _generated_cfunction_inspect_wgpu_adapter), 
    JANET_REG("wgpu-create-device", _generated_cfunction_wgpu_create_device), 
    JANET_REG("wgpu-destroy-device", _generated_cfunction_wgpu_destroy_device), 
    JANET_REG_END
  };
  janet_cfuns_ext(env, "wjpu", cfuns);
}
