@ECHO off
@if "%1"=="test" goto TEST
call cls
echo clean
call jpm clean

call jpm deps

echo copy pdb
mkdir build
copy vc140.pdb build\

echo gen
call jpm run gen

echo build
call jpm build

@if "%1"=="all" goto TEST
exit /b 0

:TEST
set RUST_BACKTRACE=full
echo test
call jpm test
