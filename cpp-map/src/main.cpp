#include <iostream>
#include <map>

int main() {
    std::map<int, std::string> myMap;

    // Insert some key-value pairs into the map
    myMap[1] = "one";
    myMap[2] = "two";
    myMap[3] = "three";

    // Iterate over the map and print the key-value pairs
    for (const auto& pair : myMap) {
        std::cout << pair.first << ": " << pair.second << std::endl;
    }

    // Access and print values by key
    std::cout << myMap.at(1) << std::endl;
    std::cout << myMap.at(2) << std::endl;
    std::cout << myMap.at(3) << std::endl;

    return 0;
}