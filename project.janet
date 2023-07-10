(declare-project
  :name "wjpu"
  :description "bindings for wgpu and glfw - written with spork/cjanet"
  :url "https://awesemble.de"
  :author "Janet Brüll <mlatu@mlatu.de>"
  :dependencies ["https://github.com/janet-lang/spork.git"]
  )

(comment ```depends on glfw and webgpu, see ./WebGPU-distribution-info.txt and ./glfw/glfw-sources-here. built and "tested" this only on windows so far

todo:
 - need to handle getting webgpu better than a zip file
 - and cloning glfw
 - needs more functions
 - move helper functions request-device/adapter into auxiliary c.file
```)

(def this-os (os/which))

(def compiler-flags
  (case this-os
    :macos '[
      "-Iglfw/include"
      "-IWebGPU-distribution-wgpu/include"
      "-ObjC"]
    
    :windows '[
      "/Zi"
      "/FS"
      "/MD"
      #"/fsanitize=address"
      "/c"
      "/O2"
      "/D_CRT_SECURE_NO_WARNINGS"
      "/W3"
      "-IWebGPU-distribution-wgpu/include"
      "-Iwebgpu-release/include"
      "-Iglfw/include"
      "-Iglfw3webgpu"
      #"-Ispork/src"
      ]

    :linux '[
      "-IWebGPU-distribution-wgpu/include/"
      "-Iwebgpu-release/include/"
      "-Iglfw/include/"
      "-Iglfw3webgpu/"
      ]

    #default
    '[
      "-IWebGPU-distribution-wgpu/include/"
      "-Iwebgpu-release/include/"
      "-Iglfw/include/"
      "-Iglfw3webgpu/"
      ]))

(def linker-flags
  (case this-os
    :windows '[
      "/DEBUG"
      "user32.lib"
      "gdi32.lib"
      "winmm.lib"
      "shell32.lib"
      "glfw/build/src/Debug/glfw3.lib"
      "WebGPU-distribution-wgpu/bin/windows-x86_64/wgpu_native.dll.lib"
      #"spork/build/spork/tarray.lib"
      "/NODEFAULTLIB:MSVCRTD"
      #"clang_rt.asan_dynamic-x86_64.lib"
      #"clang_rt.asan_dynamic_runtime_thunk-x86_64.lib
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

(def os-defines
  (case this-os
    :windows {"PLATFORM_DESKTOP" true
              "WEBGPU_BACKEND_WGPU" true
              "WJPU_C99_FORMAT" true}
    #default
              {"PLATFORM_DESKTOP" true
              "WEBGPU_BACKEND_WGPU" true
              "WJPU_ANSI_C_FORMAT" true}))

(phony "gen" []
       (os/execute ["janet" "src/glfw_wgpu_c.janet"] :p))

(def wgpu-glfw-binding
  (declare-native
    :name "wgpu-glfw-binding"
   
    :cppflags [;default-cppflags
               ;compiler-flags]
   
    :defines os-defines

    :source [
             "src/glfw_wgpu.gen.cpp"
             "glfw3webgpu/glfw3webgpu.cpp"
             ]

    :headers [
              "src/glfw.aux.hpp"
              "glfw3webgpu/glfw3webgpu.hpp"
              "glfw/include/GLFW/glfw3.h"
              "webgpu-release/include/webgpu/webgpu-release.h"
              "WebGPU-distribution-wgpu/include/webgpu/webgpu.h"
              "WebGPU-distribution-wgpu/include/webgpu/wgpu.h"
              ]
   
    :lflags [;default-lflags
             ;linker-flags]

    #:install true
    :native-deps ["spork/tarray"]
    ))

(comment
(declare-source
  :source ["src/wjpu.janet"]))

(declare-executable
  :name "demo"
  :deps @[(wgpu-glfw-binding :static)]
  :entry "demo.janet")

# `jpm run repl` to run a repl with access to jaylib
(phony "repl" ["build"]
       (os/execute ["janet" "-l" "./build/wjpu"] :p))

#(declare-executable
#  :name "test"
#  :entry "test/main.janet")
