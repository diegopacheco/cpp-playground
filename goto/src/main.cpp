#include <iostream>

int main() {
    int count = 0;

start:
    std::cout << "Count: " << count << std::endl;
    count++;

    if (count < 5) {
        goto start;
    }

    std::cout << "Finished counting." << std::endl;
    return 0;
}