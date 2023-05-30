( declare-project
  :name "wjpu"
  :description "bindings for wgpu and glfw - written with spork/cjanet"
  :url "https://awesemble.de"
  :author "Janet Brüll <mlatu@mlatu.de>")

(comment ```depends on glfw and webgpu, see ./WebGPU-distribution-info.txt and ./glfw/glfw-sources-here. built and "tested" this only on windows so far

todo:
 - need to handle getting webgpu better than a zip file
 - and cloning glfw
 - needs more functions
 - move helper functions request-device/adapter into auxiliary c.file
```)

(def this-os (os/which))

(def cflags
  (case this-os
    :macos '[
      "-Iglfw/include"
      "-IWebGPU-distribution-wgpu/include"
      "-ObjC"]
    
    :windows '[
      "-Iglfw/include"
      "-IWebGPU-distribution-wgpu/include"
      "-Iwebgpu-release/include"
      "-Iglfw3webgpu"
      "/Zi"
      "/FS"
      ]

    :linux '[
      "-Iglfw/include"
      "-IWebGPU-distribution-wgpu/include"
      "-Iwebgpu-release/include"
      "-Iglfw3webgpu"
      ]

    #default
    '[
      "-Iglfw/include"
      "-IWebGPU-distribution-wgpu/include"
      ]))

(def lflags
  (case this-os
    :windows '[
      "user32.lib"
      "gdi32.lib"
      "winmm.lib"
      "shell32.lib"
      "glfw/build/src/Debug/glfw3.lib"
      "WebGPU-distribution-wgpu/bin/windows-x86_64/wgpu_native.dll.lib"
      "/NODEFAULTLIB:MSVCRTD"
      ]
      
    :macos '[
      "-lpthread"
      "-framework" "Cocoa"
      "-framework" "CoreVideo"
      "-framework" "IOKit"
      "-framework" "OpenGL"
      ]

    :linux '[
      "-lpthread"
      "-lX11"
      "-Lglfw/build/src/"
      "-lglfw"
      "-LWebGPU-distribution-wgpu/bin/linux-x86_64/"
      "-lwgpu_native"
      ]

    #default
    '["-lpthread"]))

(phony "gen" []
       (os/execute ["janet" "src/glfw.janet"] :p))

(declare-native
 :name "wjpu"
 
 :cflags [;default-cflags
          ;cflags]
 
 :defines {"PLATFORM_DESKTOP" true
           "_POSIX_C_SOURCE" "200809L"
           "_DARWIN_C_SOURCE" (if (= this-os :macos) "1" nil)
           "WEBGPU_BACKEND_WGPU" true}

 :source ["glfw3webgpu/glfw3webgpu.c" "src/glfw.gen.c"]
 :headers ["src/glfw.aux.h"]
 
 :lflags [;default-lflags
          ;lflags])

# `jpm run repl` to run a repl with access to jaylib
(phony "repl" ["build"]
       (os/execute ["janet" "-l" "./build/wjpu"] :p))
