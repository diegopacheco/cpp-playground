#include <iostream>
#include <string>
using namespace std;

void concat(){
    cout << "string concat: " << endl;
    string firstName = "John ";
    string lastName = "Doe";
    string fullName = firstName + lastName;
    cout << fullName;
}

void append(){
    cout << "\nstring append: " << endl;
    string firstName = "John ";
    string lastName = "Doe";
    string fullName = firstName.append(lastName);
    cout << fullName;
}


void sizerOrLength(){
    cout << "\nstring size or length: " << endl;
    string firstName = "John ";
    string lastName = "Doe";
    string fullName = firstName.append(lastName);
    cout << "Full name length: " << fullName.size() << "\n";
    cout << "Full name size  : " << fullName.length() << "\n";
}

void accessString(){
    string me="Diego Pacheco";
    for(int i=0;i<me.length();i++){
        cout << me[i] << " ";
    }
}

int main(){
    concat();
    append();
    sizerOrLength();
    accessString();

    std::cout << "\nNo namespace import: ";
    std::string greeting = "Hello";
    std::cout << greeting;
    return 0;
}
