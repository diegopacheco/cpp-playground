#include <iostream>
#include <cstring>

int main() {
    const char source[] = "Hello, World!";
    char destination[50];
    std::memcpy(destination, source, sizeof(source));

    std::cout << "Source: " << source << std::endl;
    std::cout << "Destination: " << destination << std::endl;
    return 0;
}