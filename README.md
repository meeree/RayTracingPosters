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

# "Stella Corris" Fractal

I came up with this fractal back in 2016 ([first try rendering](https://youtu.be/gbqG23NxaAY?si=zRkwD5SSsJEuIC2b), using a bunch of 2D slices in X-Y-Z, [second try, a year later](https://www.youtube.com/watch?v=I6SrVbbiJyw), using marching cubes and random triangles). It turns out to be an example of a "[hyper-complex fractal](http://www.bugman123.com/Hypercomplex/)." 

With my ray-tracing code here, I can explore it in much better detail:

![image info](stella_map.jpg)

One really cool detail are the mandelbrots which are apparent in the "mini bulb" on the bottom left. 
