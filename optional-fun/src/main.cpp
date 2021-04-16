#include <iostream>
#include <optional>
using namespace std;

void optionalFun(){
    std::optional<int> i;
    if (i){
        std::cout << "Has Value" << std::endl;
    }else{
        std::cout << "Empty Value" << std::endl;
    }
}

int main(){
    optionalFun();
    return 0;
}
