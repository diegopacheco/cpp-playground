#include <iostream>
using namespace std;

consteval int sqr(int n) {
  return n * n;
}

int main(){
    constexpr int r = sqr(100); // OK
    cout << r << endl;
    return 0;
}
