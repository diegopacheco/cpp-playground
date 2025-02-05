#include <iostream>
#include <type_traits>

int main() {
    std::cout << std::boolalpha; // without this would print 0 and 1
    std::cout << std::is_integral<int>::value << '\n';
    std::cout << std::is_integral<double>::value << '\n';
    std::cout << std::is_integral<char>::value << '\n';
    return 0;
}