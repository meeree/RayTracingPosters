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

file(GLOB TRACE_SOURCE "trace.cpp")
set (TRACE_BINARY_NAME "trace")

file(GLOB TRACE_INT_SOURCE "trace_interactive.cpp")
set (TRACE_INT_BINARY_NAME "trace_interactive")

# Copy Shaders.
configure_file("vert.glsl" ${CMAKE_CURRENT_BINARY_DIR}/.. COPYONLY)
configure_file("frag.glsl" ${CMAKE_CURRENT_BINARY_DIR}/.. COPYONLY)
configure_file("vert_interactive.glsl" ${CMAKE_CURRENT_BINARY_DIR}/.. COPYONLY)
configure_file("frag_interactive.glsl" ${CMAKE_CURRENT_BINARY_DIR}/.. COPYONLY)

if (CMAKE_BUILD_TYPE MATCHES "RELEASE")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DOGLWRAP_DEBUG=0")
endif()

add_executable(${TRACE_BINARY_NAME} ${TRACE_SOURCE})
add_executable(${TRACE_INT_BINARY_NAME} ${TRACE_INT_SOURCE})


set(WINDOWS_BINARIES ${TRACE_BINARY_NAME} ${TRACE_INT_BINARY_NAME})
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR})

