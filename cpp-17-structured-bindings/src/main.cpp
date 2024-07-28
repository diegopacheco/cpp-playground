#include <iostream>
#include <unordered_map>
using namespace std;

using Coordinate = std::pair<int, int>;

Coordinate origin() {
    return Coordinate{0, 0};
}

int main() {
    const auto [ x, y ] = origin();
    cout << "x = " << x << ", y = " << y << endl;
    
    std::unordered_map<std::string, int> mapping {
        {"a", 1},
        {"b", 2},
        {"c", 3}
    };

    // Destructure by reference.
    for (const auto& [key, value] : mapping) {
        std::cout << key << " = " << value << std::endl;
    }
    return 0;
}