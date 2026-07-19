cmake_minimum_required(VERSION 3.14)
project(cybercafe_erp_windows VERSION 1.0.0 LANGUAGES CXX)

set(BINARY_NAME "CyberCafeERP")
set(APPLICATION_NAME "CyberCafe ERP Pro")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory("flutter")
add_subdirectory("runner")

set(install_bundled_lib_dir "lib")
set(INSTALL_BUNDLED_LIB_DIR ${install_bundled_lib_dir} CACHE PATH "Directory where bundled libraries are installed")
set(INSTALL_VCRUNTIME_DIR ${INSTALL_BUNDLED_LIB_DIR} CACHE PATH "Directory where vcruntime is installed")

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLED_LIB_DIR}")

install(DIRECTORY "${FLUTTER_LIBRARY_DIR}" DESTINATION "${INSTALL_BUNDLED_LIB_DIR}"
        FILES_MATCHING PATTERN "*.dll")
