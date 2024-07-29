#include <iostream>
using namespace std;

const char* g() { return "dynamic initialization"; }
constexpr const char* f(bool p) { return p ? "constant initializer" : g(); }

constinit const char* c = f(true); // OK

int main(){
    cout << c << endl;
    return 0;
}
