#!/bin/bash

oitput_ignored=$(mkdir target/ 2>&1) 
gcc -g ./src/main.c -o target/main
