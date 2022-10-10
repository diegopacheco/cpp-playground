#include <iostream>
#include <vector>
#include <map>
using namespace std;

int main(){
    std::vector<int> numbers = {1, 2, 3};
    for (auto x : numbers){
        std::cout << x << "\n";
    }

    std::map<std::string, float> fruitPrices {
        { "Apple", 0.69f },
        { "Banana", 0.89f },
        { "Orange", 1.1f },
    };
    for(auto& [k, v]: fruitPrices) {
        std::cout << k << "s cost $" << v << ".\n";
    }
}
