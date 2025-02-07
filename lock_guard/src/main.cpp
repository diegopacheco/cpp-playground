#include <iostream>
#include <thread>
#include <mutex>

std::mutex mtx;

void printMessage(const std::string& msg) {
    std::lock_guard<std::mutex> lock(mtx);
    std::cout << msg << '\n';
}

int main() {
    std::thread t1(printMessage, "Hello from thread 1");
    std::thread t2(printMessage, "Hello from thread 2");
    t1.join();
    t2.join();
    return 0;
}