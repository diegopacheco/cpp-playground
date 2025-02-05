#include <iostream>
#include <array>

// compile time evaluation of factorial
constexpr int factorial(int n) {
    return (n <= 1) ? 1 : n * factorial(n - 1);
}

int main() {
    constexpr int val = factorial(5);
    std::array<int, val> arr{};
    std::cout << arr.size() << '\n';
    return 0;
}