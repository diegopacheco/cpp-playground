#include <iostream>
using namespace std;

void print() {}

template <typename T, typename... Types>
void print(T var1, Types... var2){
    cout << "Var1: " << endl;
    cout << var1 << endl;

    cout << "Var2: " << endl;
    print(var2...);
}
 
int main(){
    print(1, 2, 3.14,
          "Pass me any "
          "number of arguments",
          "I will print\n");
    return 0;
}
