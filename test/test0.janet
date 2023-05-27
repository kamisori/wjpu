(use ../build/wjpu)

(init)

(def GLFW_CLIENT_API 0x00022001)
(def GLFW_NO_API 0)

(hint-next-window GLFW_CLIENT_API GLFW_NO_API)

(def window (create-window 200 200 "welcome window"))
(unless window
  (terminate)
  (error "could not create window"))

(def wgpu-instance (wgpu-create-instance))
(unless wgpu-instance
  (destroy-window window)
  (terminate)
  (error "could not create instance"))

(def wgpu-surface (wgpu-create-surface wgpu-instance window))
(unless wgpu-surface
  (wgpu-destroy-instance wgpu-instance)
  (destroy-window window)
  (terminate)
  (error "could not create surface"))

(def wgpu-adapter (wgpu-create-adapter wgpu-instance wgpu-surface))
(unless wgpu-adapter
  (wgpu-destroy-surface wgpu-surface)
  (wgpu-destroy-instance wgpu-instance)
  (destroy-window window)
  (terminate)
  (error "could not create adapter"))

(printf "Found %q features" (inspect-wgpu-adapter wgpu-adapter))

(def wgpu-device (wgpu-create-device wgpu-adapter))
(unless wgpu-device
  (if wgpu-adapter
    (wgpu-destroy-adapter wgpu-adapter)
    (pp "adapter already gone"))
  (if wgpu-surface
    (wgpu-destroy-surface wgpu-surface)
    (pp "surface already gone"))
  (if wgpu-instance
    (wgpu-destroy-instance wgpu-instance)
    (pp "instance already gone"))
  (if window
    (destroy-window window)
    (pp "window already gone"))
  (terminate)
  (error "could not create device"))

(while (not (close-window? window))
  (poll-events))

(if wgpu-device
  (wgpu-destroy-device wgpu-device)
  (pp "device already gone"))
(if wgpu-adapter
  (wgpu-destroy-adapter wgpu-adapter)
  (pp "adapter already gone"))
(if wgpu-surface
  (wgpu-destroy-surface wgpu-surface)
  (pp "surface already gone"))
(if wgpu-instance
  (wgpu-destroy-instance wgpu-instance)
  (pp "instance already gone"))
(if window
  (destroy-window window)
  (pp "window already gone"))

(terminate)
