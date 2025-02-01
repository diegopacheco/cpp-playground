#!/bin/bash

rm -rf target/
mkdir target/

cd target/
cmake ..
make

