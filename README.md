# buildware
Building opensources for multi-platforms with github actions.
  
[![Release](https://img.shields.io/github/v/release/axmolengine/buildware?include_prereleases&label=release)](../../releases/latest)
[![build](https://github.com/axmolengine/buildware/actions/workflows/build.yml/badge.svg)](https://github.com/axmolengine/buildware/actions/workflows/build.yml)
[![dist](https://github.com/axmolengine/buildware/actions/workflows/dist.yml/badge.svg)](https://github.com/axmolengine/buildware/actions/workflows/dist.yml)
[![Downloads](https://img.shields.io/github/downloads/axmolengine/buildware/total.svg?label=downloads&colorB=orange)](../../releases/latest)

## opensources
- [![zlib](https://img.shields.io/badge/zlib-1.2.13-green.svg)](https://github.com/madler/zlib)
- [![OpenSSL Stable Releaee](https://img.shields.io/badge/openssl-3.0.8-green.svg)](https://github.com/openssl/openssl/tags)
- [![jpeg-turbo](https://img.shields.io/badge/jpeg%2d%2dturbo-2.1.5.1-green.svg)](https://github.com/libjpeg-turbo/libjpeg-turbo/releases)
- [![curl](https://img.shields.io/badge/curl-7.88.0-green.svg)](https://github.com/curl/curl/releases)
- [![luajit](https://img.shields.io/badge/luajit-2.1%2d%2dd0e8893-green.svg)](https://github.com/LuaJIT/LuaJIT/commit/d0e8993)
- [![glsl-optimizer](https://img.shields.io/badge/glsl_optimizer-cdfc9ef-green.svg)](https://github.com/cocos2d/glsl-optimizer/commit/cdfc9ef)  - Apple Only
- [![angle](https://img.shields.io/badge/angle-chromium%2F5563-green.svg)](https://github.com/google/angle) - Windows Only


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
