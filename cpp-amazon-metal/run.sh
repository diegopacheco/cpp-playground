#!/bin/bash
set -e
cd "$(dirname "$0")"
mkdir -p target
clang++ -std=c++17 -O2 -fobjc-arc -Wno-deprecated-declarations -Wno-encode-type -framework Metal -framework MetalKit -framework Cocoa -framework QuartzCore main.mm -o target/amazon_rainforest
./target/amazon_rainforest
