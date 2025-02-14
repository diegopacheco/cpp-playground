#include <iostream>
#include <string>
using namespace std;

class StringWrapper {
private:
    string str;
public:
    // Explicit constructor to prevent implicit conversions
    explicit StringWrapper(const string& s) : str(s) {}

    // Method to access the string
    string get_string() const {
        return str;
    }
};

void printMyString(const StringWrapper& myStr) {
    cout << "StringWrapper: " << myStr.get_string() << endl;
}

int main() {
    // Direct initialization using the explicit constructor
    StringWrapper myStr1("Hello, explicit!");
    printMyString(myStr1);

    // This would cause a compilation error because the constructor is explicit
    // printMyString("Hello, implicit!"); // Error: no matching function for call to 'printMyString(const char [17])'
    // We must explicitly construct a StringWrapper object
    printMyString(StringWrapper("Hello, explicit construction!"));
    return 0;
}