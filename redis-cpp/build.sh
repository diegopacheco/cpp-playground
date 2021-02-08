#!/bin/bash

rm -rf target/
mkdir target/
g++ -o target/main main.cpp -std="c++17" -pthread -DREDISCPP_HEADER_ONLY=ON -fpermissive