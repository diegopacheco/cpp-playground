#include <iostream>
#include <variant>

int main() {
    std::variant<int, double> v = 3.14;
    std::cout << std::get<double>(v) << '\n';
    
    return 0;
}