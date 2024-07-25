#!/bin/bash

rm -rf target/
mkdir -p target/
mkdir -p gcm.cache/

# Compile custom modules first (assuming helloworld.cpp defines a module)
g++-14 -std=c++20 -fmodules-ts -c src/helloworld.cpp -o target/helloworld.o

# Then compile other files
for file in src/*.cpp; do
    if [[ $(basename -- "$file") != "helloworld.cpp" ]]; then
        filename=$(basename -- "$file")
        filename="${filename%.*}"
        
        g++-14 -std=c++20 -fmodules-ts -c "$file" -o "target/${filename}.o"
    fi
done

# Link all object files to create the executable
g++-14 -std=c++20 target/*.o -o target/main