#include <iostream>
using namespace std;

int main(){
    int *p = new(nothrow) int;
    if (!p){
        cout << "Memory allocation failed\n";
    }else{
        cout << "Memory allocation workign fine\n";
    }
    *p=42;
    cout << "p==[" << *p << "]\n";

    delete p;
    cout << "Memory deallocation!\np==[" << *p << "]";

    return 0;
}
