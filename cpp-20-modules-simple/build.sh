#!/bin/bash

rm -rf target/ gcm.cache/
mkdir -p target/ gcm.cache/

# Compile the module interface
g++-14 -std=c++20 -fmodules-ts -c src/mymath.cppm -o gcm.cache/mymath.gcm

# Correct the module search path option
# Compile the main program (assuming it imports the mymath module)
g++-14 -std=c++20 -fmodules-ts -c src/main.cpp -o target/main.o -fmodule-mapper=gcm.cache/mymath.gcm

# Link the object file to create the executable
g++-14 -std=c++20 target/main.o -o target/main