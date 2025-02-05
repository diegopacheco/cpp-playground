#include <iostream>
#include <random>

int main() {
    std::mt19937 gen{std::random_device{}()};
    std::uniform_int_distribution<> dist(1, 10);
    std::cout << dist(gen) << '\n';
    return 0;
}