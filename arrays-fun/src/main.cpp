#include <iostream>
using namespace std;

int main(){
    string cars[4] = {"Volvo", "BMW", "Ford", "Mazda"};
    int i=0;
    int size=cars->length();
    while(i<size){
        cout << cars[i] << endl;
        i++;
    }
    cout << "C++ works" << endl;
    return 0;
}
