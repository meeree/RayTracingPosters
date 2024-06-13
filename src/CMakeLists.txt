cmake_minimum_required(VERSION 2.8)

if (MSVC)
    link_libraries(opengl32)
else()
    link_libraries(GL)
endif()
link_libraries(glfw)
link_libraries(glad)

set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -fopenmp")
set (CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DUSE_DEBUG_CONTEXT -g")

if (BUILD_SHARED_LIBS)
    link_libraries("${MATH_LIBRARY}")
endif()
if (MSVC)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
endif()

set (LODEPNG_SOURCE "../deps/lodepng/lodepng.cpp")

file(GLOB FRACTAL_SOURCE "trace.cpp")
set (FRACTAL_BINARY_NAME "trace")

# Copy Shaders.
configure_file("vert.glsl" ${CMAKE_CURRENT_BINARY_DIR}/.. COPYONLY)
configure_file("frag.glsl" ${CMAKE_CURRENT_BINARY_DIR}/.. COPYONLY)

if (CMAKE_BUILD_TYPE MATCHES "RELEASE")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DOGLWRAP_DEBUG=0")
endif()

add_executable(${FRACTAL_BINARY_NAME} ${FRACTAL_SOURCE} ${ICON})

set(WINDOWS_BINARIES ${FRACTAL_BINARY_NAME})
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR})

