#include <atomic>
#include <iostream>
#include <typeinfo>
#include <cxxabi.h>
#include <memory>
#include <string>
#include <vector>

template<typename T>
void is_lock_free(std::atomic<T>& a);

std::string demangle(const char* name) {
    int status = -1;
    std::unique_ptr<char, void(*)(void*)> res {
        abi::__cxa_demangle(name, NULL, NULL, &status),
        std::free
    };
    return (status == 0) ? res.get() : name;
}

int main() {
    std::cout << "C++ Standard: " << __cplusplus << " :" << std::endl;

    std::atomic<int> x = 10;
    is_lock_free(x);

    std::atomic<double> y = 10.4;
    is_lock_free(y);

    std::atomic<char> c = 'z';
    is_lock_free(c);

    std::atomic<int*> cp = nullptr;
    is_lock_free(cp);

    std::atomic<std::shared_ptr<std::string>> z(std::make_shared<std::string>("Hello"));
    is_lock_free(z);
}

template<typename T>
void is_lock_free(std::atomic<T>& a) {
    if (std::atomic_is_lock_free(&a)) {
        std::cout << demangle(typeid(T).name()) << " is lock-free" << std::endl;
    } else {
        std::cout << demangle(typeid(T).name()) << " is NOT lock-free" << std::endl;
    }
}