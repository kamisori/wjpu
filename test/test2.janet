(use ../build/wgpu-glfw-binding)
(import spork/test :as test)

(def testname "glfw poll events")
(test/start-suite testname)

(test/assert (initialize-context)                                         "could not initialize context")
(def GLFW_CLIENT_API 0x00022001)
(def GLFW_NO_API 0)

(test/assert (hint-next-window GLFW_CLIENT_API GLFW_NO_API)               "could not give hint for next window")

(def window (test/assert (create-window 200 200 testname)   "could not create window"))
(test/assert (destroy-window nil)                                         "could not destroy nil as a window")
(test/assert (destroy-window window)                                      "could not destroy window")

(test/assert
  (when-with
    [window (test/assert (create-window 200 200 testname)     "could not create window in when-with")
            |(test/assert (destroy-window $0)                            "could not destroy window in when-with")
            ]
    (test/assert (poll-events)                                              "could not poll events")
    (test/assert-not (close-window? window)                                 "window should close just after it was created?")
    )
                                                                            "could not use when-with")

(test/assert (terminate-context) "context not terminated ._?")

(test/end-suite)

(os/exit)