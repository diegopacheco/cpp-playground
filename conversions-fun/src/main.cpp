#include <iostream>
using namespace std;

int main(){
    std::string s3("     1234567890morewords");
    unsigned long ll = std::stoul(s3);
    std::cout << "get just numbers ignore words == [     1234567890morewords]" << "\n";
    std::cout << ll << "\n";
}
