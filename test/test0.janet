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

(printf "Found %q features" (wgpu-inspect-adapter wgpu-adapter))

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

(wgpu-device-set-uncaptured-error-callback wgpu-device)

(def wgpu-queue (wgpu-device-create-queue wgpu-device))

(def wgpu-swapchain (wgpu-device-create-swapchain wgpu-device wgpu-adapter wgpu-surface))


(def cmdbuff (create-command-buffer))

(while (not (close-window? window))
  (poll-events)

  (def nextTexture (wgpu-swapchain-create-next-textureview wgpu-swapchain))
  # Getting the texture may fail, in particular if the window has been resized
  # and thus the target surface changed.
  (when (nil? nextTexture)
    (printf "Cannot acquire next swap chain texture")
    (break))
  (def wgpu-commandencoder (wgpu-device-get-command-encoder wgpu-device))

  (def renderPass (wgpu-get-example-renderpass wgpu-commandencoder nextTexture))
  (wgpu-render-pass-encoder-end renderPass)

  (wgpu-destroy-textureview nextTexture)

  (wgpu-command-encoder-insert-debug-marker wgpu-commandencoder "hello world")
  (wgpu-command-encoder-finish-ref wgpu-commandencoder cmdbuff)

  (wgpu-queue-submit wgpu-queue 1 cmdbuff)
  (wgpu-swapchain-present wgpu-swapchain)
  )

(destroy-command-buffer cmdbuff)

(wgpu-destroy-queue wgpu-queue)
(if wgpu-swapchain
  (wgpu-destroy-swapchain wgpu-swapchain)
  (pp "swapchain already gone"))
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
