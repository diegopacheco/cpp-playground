#!/bin/bash

rm -rf target/
mkdir -p target/

# Compile the module interface
g++-14 -std=c++20 -fmodules-ts -c src/helloworld.cpp -o target/helloworld.o

# Compile the main program (assuming it imports the mymath module)
g++-14 -std=c++20 -fmodules-ts -c src/main.cpp -o target/main.o -fmodule-mapper=target/helloworld.o

# Link the object file to create the executable
g++-14 -std=c++20 target/main.o -o target/main