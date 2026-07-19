cmake_minimum_required(VERSION 3.14)
project(cybercafe_erp LANGUAGES CXX)

set(BINARY_NAME "CyberCafeERP")
set(APP_NAME "CyberCafe ERP Pro")
set(COMPANY_NAME "CyberCafe ERP")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/runner_version.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/runner_version.h
  @ONLY
)

set(CRITICAL_SOURCES
  "main.cpp"
  "flutter_window.cpp"
  "utils.cpp"
  "win32_window.cpp"
)

add_executable(${BINARY_NAME} WIN32
  ${CRITICAL_SOURCES}
  "runner.exe.manifest"
  "runner.rc"
)

apply_standard_settings(${BINARY_NAME})

target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_link_libraries(${BINARY_NAME} PRIVATE "shlwapi.lib")
add_dependencies(${BINARY_NAME} flutter_assemble)
