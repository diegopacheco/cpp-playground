#!/bin/bash

rm -rf target/
mkdir target/
g++ -std=c++17 -o target/main src/main.cpp 