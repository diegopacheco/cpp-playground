#!/bin/bash

rm -rf target/ gcm.cache/
mkdir -p target/ gcm.cache/

g++ -std=c++20 -fmodules-ts -xc++-system-header iostream
g++ -std=c++20 -fmodules-ts -c src/advanced_mathematics.cc -o target/advanced_mathematics.o
g++ -std=c++20 -fmodules-ts -c src/main.cc -o target/main.o

g++ -std=c++20 target/main.o target/advanced_mathematics.o -o target/main