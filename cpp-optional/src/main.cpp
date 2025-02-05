#include <iostream>
#include <optional>

std::optional<int> maybeGetInt(bool give) {
    if(give) return 42;
    return {};
}

int main() {
    auto val = maybeGetInt(true);
    if(val) {
        std::cout << "First try: " << *val << '\n';
    }

    val = maybeGetInt(false);
    if(val) {
        std::cout << "Second try: " << *val << '\n';
    }
    return 0;
}