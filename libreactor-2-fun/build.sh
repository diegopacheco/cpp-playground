#!/bin/bash

rm -rf target/
mkdir target/
gcc -Wall -Wpedantic -march=native -flto -O3 src/*.c -o target/main -lreactor -ldynamic -pthread