#include <iostream>
using namespace std;

template <typename... Args>
auto sum(Args... args) {
    // Unary folding.
    return (... + args);
}

int main(){
    cout << sum(1.0, 2.0f, 3) << endl;
    return 0;
}
