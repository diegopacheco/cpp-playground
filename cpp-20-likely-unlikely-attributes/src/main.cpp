#include <iostream>
using namespace std;

void printMe(int n){
    switch(n){
        [[likely]] case 1:
            cout << "One" << endl;
        break;
        [[likely]] case 2:
            cout << "Two" << endl;
        break;
        [[unlikely]] case 3:
            cout << "Three" << endl;
        break;
        [[unlikely]] default:
            cout << "Unknown" << endl;
        break;
    }
}

int main(){
    cout << "Tell the optimizer what is likely or unlikely to happen" << endl;
    printMe(1);
    return 0;
}
