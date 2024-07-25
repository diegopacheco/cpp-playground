#!/bin/bash

rm -rf target/
mkdir -p target/
mkdir -p gcm.cache/

# Compile the module interface unit for 'helloworld'
g++-11 -std=c++20 -fmodules-ts -c src/helloworld.cpp -o target/helloworld.o

# Compile the main program
g++-11 -std=c++20 -fmodules-ts -c src/main.cpp -o target/main.o

# Link the program
g++-11 -std=c++20 -o target/main target/helloworld.o target/main.o