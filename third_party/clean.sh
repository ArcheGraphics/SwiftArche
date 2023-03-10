#!/bin/bash
set -x

# PhysX #################################### 
cd physx/physx

cd compiler/linux-debug
make clean
cd ..

cd linux-release
make clean
cd ../../../../

# OZZ #####################################
cd ozz
rm -rf build_release
rm -rf build_debug
cd ..

set +x
