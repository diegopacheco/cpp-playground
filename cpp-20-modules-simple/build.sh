#!/bin/bash

rm -rf target/
mkdir -p target/

# Compile each .cpp file to an object file
for file in src/*.cpp; do
    # Extract the filename without the extension
    filename=$(basename -- "$file")
    filename="${filename%.*}"
    
    # Compile the file to an object file
    g++-14 -std=c++20 -fmodules-ts -c "$file" -o "target/${filename}.o"
done

# Link all object files to create the executable
g++-14 -std=c++20 target/*.o -o target/main