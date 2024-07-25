#!/bin/bash

rm -rf target/ gcm.cache/
mkdir -p target/ gcm.cache/

g++ -std=c++20 -fmodules-ts -c src/mymath.cppm -o gcm.cache/mymath.gcm

#g++ -std=c++20 -fmodules-ts -c src/main.cpp -o target/main.o -fmodule-file=gcm.cache/mymath.gcm

#g++ target/main.o -o target/main