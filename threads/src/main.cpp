#include <iostream>
#include <thread>

void threadFunction() {
    std::cout << "Hello from thread!\n";
}

int main() {
    std::thread t(threadFunction);
    t.join();
    return 0;
}