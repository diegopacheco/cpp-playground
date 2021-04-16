#!/bin/bash

rm -rf target/
mkdir target/
g++ -o target/main src/main.cpp -l sqlite3
