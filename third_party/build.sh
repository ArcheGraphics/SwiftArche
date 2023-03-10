#!/bin/bash
set -x

# cmake .. -G Xcode -DCMAKE_TOOLCHAIN_FILE=../../ios-cmake/ios.toolchain.cmake -DPLATFORM=OS64

# PhysX #################################### 
cd physx/physx
./generate_projects.sh linux

cd compiler/linux-debug
make -j5
cd ..

cd linux-release
make -j5
cd ../../../../

# OZZ-Animation ###########################
cd ozz
mkdir build_release
cd build_release
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j5
cd ..

mkdir build_debug
cd build_debug
cmake -DCMAKE_BUILD_TYPE=Debug ..
make -j5
cd ../..

set +x
