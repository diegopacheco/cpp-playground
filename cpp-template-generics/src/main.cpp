#include <iostream>

template<typename T>

class Box {
  T value;
public:
  Box(T v): value(v) {}
  T get() const { return value; }
};

int main() {
    Box<int> b(123);
    std::cout << b.get() << '\n';
    return 0;
}