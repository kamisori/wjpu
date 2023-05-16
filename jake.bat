@ECHO off
call jpm run gen
call jpm build
call jpm test
