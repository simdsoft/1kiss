# buildware
Building opensources for multi-platforms with github actions.
  
[![Release](https://img.shields.io/badge/dynamic/json.svg?label=release&url=https%3A%2F%2Fapi.github.com%2Frepos%2Fadxeproject%2Fbuildware%2Freleases%2Flatest&query=%24.name&colorB=blue)](../../releases/latest)
[![build-ci](https://github.com/adxeproject/buildware/actions/workflows/build-ci.yml/badge.svg)](https://github.com/adxeproject/buildware/actions/workflows/build-ci.yml)
[![dist-ci](https://github.com/adxeproject/buildware/actions/workflows/dist-ci.yml/badge.svg)](https://github.com/adxeproject/buildware/actions/workflows/dist-ci.yml)

## opensources
- [![OpenSSL Stable Releaee](https://img.shields.io/badge/openssl-3.0.1-green.svg)](https://github.com/openssl/openssl/releases)
- [![libjpeg-turbo](https://img.shields.io/badge/libjpegturbo-2.1.3-green.svg)](https://github.com/libjpeg-turbo/libjpeg-turbo/releases)
- [![curl](https://img.shields.io/badge/curl-7.82.0-green.svg)](https://github.com/curl/curl/releases)
- [![luajit](https://img.shields.io/badge/luajit-2.1%2d%2df004a51-green.svg)](https://github.com/LuaJIT/LuaJIT/commit/f004a51)

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
  - x86_64
