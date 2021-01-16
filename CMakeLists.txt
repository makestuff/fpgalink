cmake_minimum_required(VERSION 3.10)
project(fpgalink)

# Platform-specific settings
if(MSVC)
  set(CMAKE_INSTALL_BINDIR bin)
  set(CMAKE_INSTALL_LIBDIR bin)
  add_compile_options(/W4 /WX /DBYTE_ORDER=1234 /D_CRT_SECURE_NO_WARNINGS)
elseif (MINGW)
  set(CMAKE_INSTALL_BINDIR bin)
  set(CMAKE_INSTALL_LIBDIR bin)
  add_compile_options(-Wall -Wextra -pedantic -Werror -DBYTE_ORDER=1234 -DWIN32 -D_WIN32)
else()
  include(GNUInstallDirs)
  add_compile_options(-Wall -Wextra -pedantic -Werror -DBYTE_ORDER=1234)
endif()

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})

# Use C++17 and C99
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_EXTENSIONS 0)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_EXTENSIONS 0)

# Maybe build GoogleTest
if(BUILD_TESTING)
  include(CTest)
  set(GOOGLETEST_VERSION 1.10.0)
  add_subdirectory("googletest/googlemock")
endif()

# Build components
add_subdirectory("common")
add_subdirectory("libargtable2")
add_subdirectory("liberror")
add_subdirectory("libdump")
add_subdirectory("libusbwrap")
add_subdirectory("libbuffer")
add_subdirectory("libfx2loader")
add_subdirectory("libfpgalink")
