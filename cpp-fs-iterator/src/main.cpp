#include <iostream>
#include <filesystem>

int main() {
    for(auto& p: std::filesystem::directory_iterator(".")) {
        std::cout << p.path().string() << '\n';
    }
    return 0;
}