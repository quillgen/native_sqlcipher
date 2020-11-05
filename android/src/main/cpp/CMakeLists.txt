cmake_minimum_required(VERSION 3.4.1)
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/openssl/include
)

add_library(
    libcrypto
    SHARED
    IMPORTED
)

set_target_properties(
    libcrypto
    PROPERTIES
    IMPORTED_LOCATION
    ${CMAKE_CURRENT_SOURCE_DIR}/../jniLibs/${ANDROID_ABI}/libcrypto.so
)

add_library( native_sqlcipher
             SHARED
             ../../../../ios/Classes/sqlite3.c)

target_link_libraries(
    native_sqlcipher
    libcrypto)
