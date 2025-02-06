#include <iostream>

#define DEBUG

int main() {
#ifdef DEBUG
    std::cout << "Debug mode is enabled.\n";
#else
    std::cout << "Debug mode is disabled.\n";
#endif
    return 0;
}