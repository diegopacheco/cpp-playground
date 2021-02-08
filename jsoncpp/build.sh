#!/bin/bash

rm -rf target/
mkdir target/
g++ -o target/main main.cpp -ljsoncpp