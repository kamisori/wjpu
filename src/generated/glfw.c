#include <janet.h>
#include <GLFW/glfw3.h>
#include <webgpu/webgpu.h>
#include <webgpu/webgpu-release.h>

/* Initializes the GLFW context, run once to setup the library.returns false on [failure](https://www.glfw.org/docs/latest/intro_guide.html#error_handling) */
static int init() {
  return glfwInit();
}

JANET_FN(_generated_cfunction_init, "(init)", "Initializes the GLFW context, run once to setup the library.returns false on [failure](https://www.glfw.org/docs/latest/intro_guide.html#error_handling)") {
  janet_fixarity(argc, 0);
  return janet_wrap_boolean(init());
}

/* Terminates the GLFW context, run once to shutdown the context. If you need GLFW afterwards, call init again to start it back up. If init failed, this does not have to be called. [maybe a convenience script for this?](https://janet-lang.org/api/index.html#with) */
static int terminate() {
  glfwTerminate();
  return 1;
}

JANET_FN(_generated_cfunction_terminate, "(terminate)", "Terminates the GLFW context, run once to shutdown the context. If you need GLFW afterwards, call init again to start it back up. If init failed, this does not have to be called. [maybe a convenience script for this?](https://janet-lang.org/api/index.html#with)") {
  janet_fixarity(argc, 0);
  return janet_wrap_number(terminate());
}

/* Creates a window (* GLFWwindow)
hosted by the previously initialized GLFW3 context.
optionally takes a monitor (* GLFWmonitor) [to enable true fullscreen, give a monitor you retrieved here](https://www.glfw.org/docs/latest/monitor_guide.html#monitor_monitors)
and a share of a window (* GLFWwindow) [to share its context objects with](https://www.glfw.org/docs/latest/context_guide.html#context_sharing)
Returns a wrapped pointer to the window object inside glfwspace. */
static void * create_window(int width, int height, const char * title, void *monitor, void *share) {
  return glfwCreateWindow(width, height, title, monitor, share);
}

JANET_FN(_generated_cfunction_create_window, "(create-window width:int height:int title:cstring &opt (monitor :pointer NULL) (share :pointer NULL))", "Creates a window (* GLFWwindow)\nhosted by the previously initialized GLFW3 context.\noptionally takes a monitor (* GLFWmonitor) [to enable true fullscreen, give a monitor you retrieved here](https://www.glfw.org/docs/latest/monitor_guide.html#monitor_monitors)\nand a share of a window (* GLFWwindow) [to share its context objects with](https://www.glfw.org/docs/latest/context_guide.html#context_sharing)\nReturns a wrapped pointer to the window object inside glfwspace.") {
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

JANET_FN(_generated_cfunction_destroy_window, "(destroy-window window:pointer)", "calls `void glfwDestroyWindow(window)` in order to destroy window (* GLFWWindow). Returns 1, to uh.. to report the function ran properly.") {
  janet_fixarity(argc, 1);
  void *window = janet_getpointer(argv, 0);
  return janet_wrap_number(destroy_window(window));
}

/* gives hints to the next call to create-window. [keywords to be implemented](https://www.glfw.org/docs/latest/window_guide.html#window_hints) */
static int hint_next_window(int hint, int value) {
  glfwWindowHint(hint, value);
  return 1;
}

JANET_FN(_generated_cfunction_hint_next_window, "(hint-next-window hint:int value:int)", "gives hints to the next call to create-window. [keywords to be implemented](https://www.glfw.org/docs/latest/window_guide.html#window_hints)") {
  janet_fixarity(argc, 2);
  int hint = janet_getinteger(argv, 0);
  int value = janet_getinteger(argv, 1);
  return janet_wrap_number(hint_next_window(hint, value));
}

/* returns whether or not the window is supposed to close  */
static int close_window_X63(void *window) {
  return glfwWindowShouldClose(window);
}

JANET_FN(_generated_cfunction_close_window_X63, "(close-window? window:pointer)", "returns whether or not the window is supposed to close ") {
  janet_fixarity(argc, 1);
  void *window = janet_getpointer(argv, 0);
  return janet_wrap_boolean(close_window_X63(window));
}

/* polls for events */
static int poll_events() {
  glfwPollEvents();
  return 1;
}

JANET_FN(_generated_cfunction_poll_events, "(poll-events)", "polls for events") {
  janet_fixarity(argc, 0);
  return janet_wrap_boolean(poll_events());
}

JANET_MODULE_ENTRY(JanetTable *env) {
  JanetRegExt cfuns[] = {JANET_REG("init", _generated_cfunction_init), JANET_REG("terminate", _generated_cfunction_terminate), JANET_REG("create-window", _generated_cfunction_create_window), JANET_REG("destroy-window", _generated_cfunction_destroy_window), JANET_REG("hint-next-window", _generated_cfunction_hint_next_window), JANET_REG("close-window?", _generated_cfunction_close_window_X63), JANET_REG("poll-events", _generated_cfunction_poll_events), JANET_REG_END};
  janet_cfuns_ext(env, "jlfw", cfuns);
}
