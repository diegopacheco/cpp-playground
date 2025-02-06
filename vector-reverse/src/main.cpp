#include <iostream>
#include <vector>
#include <algorithm> // Include algorithm for std::reverse

int main() {
    std::vector<int> v {1, 2, 3};
    std::reverse(v.begin(), v.end());
    for (auto x : v) std::cout << x << ' ';
    return 0;
}