#!/bin/bash

rm -rf target/
mkdir target/
g++ -std=c++2b -o target/main src/*.cpp
