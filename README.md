# buildware
Building opensources for multi-platforms with github actions.
  
[![Releaee](https://img.shields.io/badge/release-1.1.1-blue.svg)](https://github.com/adxeproject/buildware/releases)
[![build-ci](https://github.com/adxeproject/buildware/actions/workflows/build-ci.yml/badge.svg)](https://github.com/adxeproject/buildware/actions/workflows/build-ci.yml)
[![dist-ci](https://github.com/adxeproject/buildware/actions/workflows/dist-ci.yml/badge.svg)](https://github.com/adxeproject/buildware/actions/workflows/dist-ci.yml)

## opensources
- [![OpenSSL Stable Releaee](https://img.shields.io/badge/openssl-1.1.1l-green.svg)](https://github.com/openssl/openssl/releases)
- [![libjpeg-turbo](https://img.shields.io/badge/libjpegturbo-2.1.1-green.svg)](https://github.com/libjpeg-turbo/libjpeg-turbo/releases)
- [![curl](https://img.shields.io/badge/curl-7.79.0-green.svg)](https://github.com/curl/curl/releases)
- [![curl](https://img.shields.io/badge/luajit-2.1.8ff09d9-green.svg)](https://github.com/LuaJIT/LuaJIT/commit/8ff09d9f5ad5b037926be2a50dc32b681c5e7597)

## Build Targets:
- macos: x86_64
- linux: x86_64
- ios:
  - armv7 (**DEPRECATED**)
  - arm64
  - x86_64 simulator
- android
  - armv7
  - arm64
  - x86
- windows
  - x86
  - x86_64 (build, but not dist yet)
