#include <bitset>
#include <iostream>
 
int main(){
    
    std::bitset<4> x { 0b1100 };
 
    std::cout << x << '\n';
    std::cout << (x >> 1) << '\n'; // shift right by 1, yielding 0110
    std::cout << (x << 1) << '\n'; // shift left by 1, yielding 1000

    /*
    0 1 0 1 AND
    0 1 1 0
    --------
    0 1 0 0
    */
    // bitwise and
    std::cout << (std::bitset<4>{ 0b0101 } & std::bitset<4>{ 0b0110 }); 
    return 0;
}