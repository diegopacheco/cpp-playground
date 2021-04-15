#include <iostream>
using namespace std;

int main(){
    string food = "Pizza"; // food variable
    string &meal = food;   // reference to food
    string* ptr = &food;   // A pointer variable, with the name ptr, that stores the address of food

    cout << food << "\n";  // Outputs Pizza
    cout << meal << "\n";  // Outputs Pizza

    cout << &food << "\n"; // Outputs 0x7ffc06a66110
    cout << &meal << "\n"; // Outputs 0x7ffc06a66110
    cout << ptr << "\n";   // Outputs 0x7ffc06a66110

    // Dereference: Output the value of food with the pointer (Pizza)
    cout << *ptr << "\n";

    return 0;
}
