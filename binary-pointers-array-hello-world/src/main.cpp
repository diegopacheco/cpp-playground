#include <iostream>

int main() {
    int binaryArray[] = {
        0b01001000, // H
        0b01100101, // e
        0b01101100, // l
        0b01101100, // l
        0b01101111, // o
        0b00101100, // ,
        0b00100000, // (space)
        0b01010111, // W
        0b01101111, // o
        0b01110010, // r
        0b01101100, // l
        0b01100100, // d
        0b00100001  // !
    };
    int* ptr = binaryArray;
    int size = sizeof(binaryArray) / sizeof(int);

    for (int i = 0; i < size; ++i) {
        char ch = static_cast<char>(*ptr);
        std::cout << ch;
        ptr++;
    }

    return 0;
}