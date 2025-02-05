#include <iostream>

template<typename... Args>
auto reduce(Args... args) {
    return (... + args);
}

int main() {
    std::cout << reduce(1,2,3,4) << '\n';
    return 0;
}