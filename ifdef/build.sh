#!/bin/bash

rm -rf target/
mkdir target/
g++ -std=c++20 -DDEBUG -o target/main src/*.cpp #-ljsoncpp
