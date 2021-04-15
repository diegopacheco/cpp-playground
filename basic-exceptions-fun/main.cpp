#include <iostream>
using namespace std;

int main(){
    try{
        int age = 15;
        if (age >= 18){
            cout << "Access granted - you are old enough.";
        }
        else{
            throw(age);
        }
    }
    catch (int myNum){
        cout << "Access denied - You must be at least 18 years old.\n";
        cout << "Age is: " << myNum << "\n\n";
    }

    try{
        int age = 15;
        if (age >= 18){
            cout << "Access granted - you are old enough.";
        }
        else{
            throw 505;
        }
    }
    catch (...){
        cout << "Catching all kinds of exceptions. Access denied - You must be at least 18 years old.\n";
    }

    return 0;
}