#include <iostream>
#include <tuple>

int main() {
    auto [x, y] = std::pair{20, 30};
    std::cout << x << ", " << y << '\n';
    return 0;
}