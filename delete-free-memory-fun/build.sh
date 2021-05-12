#!/bin/bash

rm -rf target/
mkdir target/
g++ -o target/main src/*.cpp #-ljsoncpp
