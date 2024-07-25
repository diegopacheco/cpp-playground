#!/bin/bash

rm -rf target/
mkdir -p target/

g++-14 -std=c++20 -fmodules-ts -c src/*.cpp -o target/main
