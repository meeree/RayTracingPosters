![image info](out_v2_bloom.jpg)

# RayTracingPosters
Some simple code in opengl for raytracing high-resolution posters. 

# Cloning
**To clone:** `git clone --recurse-submodules https://github.com/meeree/RayTracingPosters.git` 

You need to get the submodules, since these are the external code dependencies. They get cloned into the folder `deps`.

# Installation
Just use CMake. On Windows, you can use the GUI. On linux, you run the following:
`
mkdir build
cd build
cmake ..
make -j8
`

# Running
The code can be run as an executable with optional arguments:

`./trace [width height] [outputfile.tga]`

where `width` and `height` are in pixels and `outputfile.tga` is the output filename, which must be a tga.
