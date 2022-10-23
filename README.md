# buildware
Building opensources for multi-platforms with github actions.
  
[![Release](https://img.shields.io/github/v/release/axis-project/buildware?include_prereleases&label=release)](../../releases/latest)
[![build-ci](https://github.com/axmolengine/buildware/actions/workflows/build-ci.yml/badge.svg)](https://github.com/axis-project/buildware/actions/workflows/build-ci.yml)
[![dist-ci](https://github.com/axmolengine/buildware/actions/workflows/dist-ci.yml/badge.svg)](https://github.com/axis-project/buildware/actions/workflows/dist-ci.yml)

## opensources
- [![zlib](https://img.shields.io/badge/zlib-1.2.13-green.svg)](https://github.com/madler/zlib)
- [![OpenSSL Stable Releaee](https://img.shields.io/badge/openssl-3.0.5-green.svg)](https://github.com/openssl/openssl/tags)
- [![jpeg-turbo](https://img.shields.io/badge/jpeg-turbo-2.1.4-green.svg)](https://github.com/libjpeg-turbo/libjpeg-turbo/releases)
- [![curl](https://img.shields.io/badge/curl-7.85.0-green.svg)](https://github.com/curl/curl/releases)
- [![luajit](https://img.shields.io/badge/luajit-2.1%2d%2d6c4826f-green.svg)](https://github.com/LuaJIT/LuaJIT/commit/6c4826f)
- [![glsl-optimizer](https://img.shields.io/badge/glsl_optimizer-cdfc9ef-green.svg)](https://github.com/cocos2d/glsl-optimizer/commit/cdfc9ef)  - Apple Only
- [![angle](https://img.shields.io/badge/angle-chromium%2F5195-green.svg)](https://github.com/google/angle) - Windows Only


## Build Targets:
- macos: 
  - arm64 (M1+)
  - x86_64
- linux: x86_64
- ios:
  - arm64
  - x86_64 simulator
- tvos:
  - arm64
  - x86_64 simulator
- android
  - armv7
  - arm64
  - x86
  - x86_64
- windows
  - x86
  - x86_64
