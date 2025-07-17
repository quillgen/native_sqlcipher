# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(native_sqlcipher_library VERSION 0.0.1 LANGUAGES C)

add_library(native_sqlcipher SHARED
  "native_sqlcipher.c"
  "sqlite3.c"
)

set_target_properties(native_sqlcipher PROPERTIES
  PUBLIC_HEADER native_sqlcipher.h
  OUTPUT_NAME "native_sqlcipher"
)

target_compile_definitions(native_sqlcipher PUBLIC 
  DART_SHARED_LIB
  SQLITE_ENABLE_FTS5
  SQLITE_HAS_CODEC
  SQLITE_TEMP_STORE=2
  SQLITE_EXTRA_INIT=sqlcipher_extra_init
  SQLITE_EXTRA_SHUTDOWN=sqlcipher_extra_shutdown
  SQLITE_API=FFI_PLUGIN_EXPORT
)

find_package(OpenSSL REQUIRED)
target_link_libraries(native_sqlcipher PRIVATE OpenSSL::Crypto)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(native_sqlcipher PRIVATE "-Wl,-z,max-page-size=16384")
endif()

message(FATAL_ERROR "THIS IS THE CMakeLists.txt IN USE!")