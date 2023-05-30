# WJPU

native Janet bindings for [wgpu](https://eliemichel.github.io/LearnWebGPU/getting-started/hello-webgpu.html) and [glfw](https://github.com/glfw/glfw)

---


There is my [development fossil repository](https://www.awesemble.de/cgi-bin/fossil/public/wjpu) you may clone, but if you prefer git, you may clone https://github.com/kamisori/wjpu instead.

Issues should be filed on github.

You can also follow the project on [cohost](https://cohost.org/wjpu)

My workflow is in fossil, so the github repo might be a bit outdated, eventually i should implement some sort of automatism to keep the repos in sync, but for now i am ok with doing it by hand every week or so. Whenever i make some progress i will make a commit on github :D

For "bleeding egde", clone [this](https://www.awesemble.de/cgi-bin/fossil/public/wjpu) fossil repo as below.

---


#### Clone
```
fossil open https://www.awesemble.de/cgi-bin/fossil/public/wjpu --workdir wjpu --repodir ..
```

will give you a similar experience to 

```
git clone https://github.com/kamisori/wjpu
```

except you will end up with a wjpu.fossil file in the folder above the workdir.

i like to put a `.fossil` folder containing all the files like: `*.fossil` somewhere like the root of the folder holding the workfolders. This way the workfolder isn't cluttered with database files. there is actually no requirement for the `*.fossil` fileextension at this time, so you could name it .fossil.reponame instead and have it hidden and also "namespaced" away in autocomplete but in the same folder still.

i know it doesnt matter if you give a program a path to a directory with or without the ending slash/backslash, but it just ticks me off when autocomplete bumps into the databasefile's dot in its name when cd-ing from my work dir into a projects workdir, or at all on autocomplete in the shell... i dont want to interact with the fossil databasefile directly (most of the time).

---
#### Prerequisites
for the purpose of this document i will refer to this projects root as `./wjpu/`


###### WebGPU-distribution
Download the wgpu distribution for 'any' platform to use this projects jpm file. see also [eliemichels](https://eliemichel.github.io/LearnWebGPU/getting-started/hello-webgpu.html) tutorial on webgpu which i used to write all this.

 - [direct link to any platform wgpu distribution](https://github.com/eliemichel/WebGPU-distribution/archive/refs/heads/wgpu.zip)

copy to your ./wjpu/ and extract like e.g. this:
`unzip WebGPU-distribution-wgpu.zip`

you should end up with a folderstructure like:
`./wjpu/WebGPU-distribution-wgpu/include/webgpu/`


###### webgpu-release shim

also the [webgpu-release](https://eliemichel.github.io/LearnWebGPU/_downloads/e3b4b7e5d37965df6f754314ef616019/webgpu-release.h) compatibility shim to make a transition to dawn easier in the future. Put this file into:
`./wjpu/webgpu-release/include/webgpu/webgpu-release.h`


###### git clone the following into ./wjpu/:

 - [https://github.com/eliemichel/glfw3webgpu](https://github.com/eliemichel/glfw3webgpu)
 - [https://github.com/glfw/glfw](https://github.com/glfw/glfw)


###### build glfw
in ./wjpu/ execute:

```
cmake -S ./glfw/ -B ./glfw/build/
cmake --build ./glfw/build/
```

#### Build
clone repo and position yourself into its root, then run the c code generating rule before building to get fresh bindings made out of cjanet code:

```
jpm run gen
jpm build
jpm test
```

on windows you could just call jake.bat and it'll do all that in one go.
i added a jake.sh for similar convenience on linux
