
cmake_minimum_required(VERSION 3.23)

project(dmcp)

message(STATUS "CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}")
if(NOT WIN32)
  execute_process(COMMAND /bin/sh "${CMAKE_CURRENT_SOURCE_DIR}/dmcp.sh" "${CMAKE_CXX_COMPILER}")
endif()

