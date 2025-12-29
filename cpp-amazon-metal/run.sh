#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"
mkdir -p target
clang++ -std=c++17 -O2 -fobjc-arc -Wno-deprecated-declarations -Wno-encode-type -framework Metal -framework MetalKit -framework Cocoa -framework QuartzCore -framework ApplicationServices main.mm -o target/amazon_rainforest
./target/amazon_rainforest
