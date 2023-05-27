This is just a manual mirror of my development repository: https://www.awesemble.de/cgi-bin/fossil/public/wjpu/home

My workflow is in fossil, so this github repo might be a bit outdated, eventually i should implement some sort of automatism to keep the repos in sync, but for now i am ok with doing it by hand every week or so.
Whenever i make some progress i will make a commit here :D

For "bleeding egde", clone the fossil repo as below.

---

native Janet bindings for [wgpu](https://eliemichel.github.io/LearnWebGPU/getting-started/hello-webgpu.html) and [glfw](https://github.com/glfw/glfw)

---

#### Build
clone repo and position yourself into its root, then run:
```
jpm run gen
jpm build
jpm test
```

on windows you could just call jake.bat and it'll do all that in one go.

---

[follow on cohost](https://cohost.org/wjpu)


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
