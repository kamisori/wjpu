#!/bin/sh
clear

jpm clean
jpm deps

jpm run gen
jpm build
cp ./WebGPU-distribution-wgpu/bin/linux-x86_64/libwgpu_native.so ./build/libwgpu_native.so

set RUST_BACKTRACE=full
jpm test
