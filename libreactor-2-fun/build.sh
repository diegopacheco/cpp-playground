#!/bin/bash

rm -rf target/
mkdir target/
gcc -Wall -Wpedantic -march=native -flto -O3 -static src/*.c -o target/main -lreactor -ldynamic