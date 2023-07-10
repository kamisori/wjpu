(use ../build/wgpu-glfw-binding)
(import spork/test :as test)

(def testname "glfw-context")
(test/start-suite testname)

(test/assert (initialize-context) "could not initialize context")
(def GLFW_CLIENT_API 0x00022001)
(def GLFW_NO_API 0)

(test/assert (hint-next-window GLFW_CLIENT_API GLFW_NO_API) "could not give hint for next window")

(test/assert (terminate-context) "context not terminated ._?")

(test/end-suite)

(os/exit)