# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(native_sqlcipher_library VERSION 0.0.1 LANGUAGES C CXX)

add_library(native_sqlcipher SHARED
  "native_sqlcipher.c"
  "sqlite3.c"
  "entry.cc"
  "pinyin.cc"
  "simple_highlight.cc"
  "simple_tokenizer.cc"
  "simple_init.c"
)

set(CMAKE_CXX_STANDARD 14)
set(CXX_STANDARD_REQUIRED)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
if (APPLE)
   set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE STRING "")
   set(CMAKE_OSX_DEPLOYMENT_TARGET "10.11" CACHE STRING "Minimum OS X deployment version")
endif()

if (IOS)
  list(APPEND CMAKE_ARGS
    "-DPLATFORM=${PLATFORM}"
  )
endif()


set_target_properties(native_sqlcipher PROPERTIES
  PUBLIC_HEADER native_sqlcipher.h
  OUTPUT_NAME "native_sqlcipher"
)

target_compile_definitions(native_sqlcipher PUBLIC 
  DART_SHARED_LIB
  SQLITE_ENABLE_FTS5
  SQLITE_HAS_CODEC
  SQLITE_TEMP_STORE=2
  SQLITE_EXTRA_INIT=combined_sqlite_init
  SQLITE_EXTRA_SHUTDOWN=sqlcipher_extra_shutdown
  # SQLITE_API=FFI_PLUGIN_EXPORT
  USE_JIEBA=1
)

target_include_directories(native_sqlcipher PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_BINARY_DIR}/include
)

include(contrib/CMakeRC.cmake)
cmrc_add_resource_library(PINYIN_TEXT TYPE OBJECT NAMESPACE pinyin_text contrib/pinyin.txt)
# https://github.com/vector-of-bool/cmrc/issues/17#issuecomment-659501280
set_property(TARGET PINYIN_TEXT PROPERTY POSITION_INDEPENDENT_CODE ON)

find_package(OpenSSL REQUIRED)
target_link_libraries(native_sqlcipher PRIVATE PINYIN_TEXT OpenSSL::Crypto)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(native_sqlcipher PRIVATE "-Wl,-z,max-page-size=16384")
endif()