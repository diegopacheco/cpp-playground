#include <iostream>
#include <vector>
#include <string>

int main() {
    std::vector<std::string> myVector;
    myVector.push_back("Hello");
    myVector.push_back("World");
    myVector.push_back("!");

    for (const auto& str : myVector) {
        std::cout << str << " ";
    }
    std::cout << std::endl;

    std::cout << myVector[0] << std::endl;
    std::cout << myVector[1] << std::endl;
    std::cout << myVector[2] << std::endl;

    return 0;
}