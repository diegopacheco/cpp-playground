#include <iostream>
#include <sstream>
#include <iomanip>
using namespace std;

string stringToHex(const string& input) {
    stringstream ss;
    for (char c : input) {
        ss << hex << setw(2) << setfill('0') << (int)c;
    }
    return ss.str();
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        cout << "Usage: " << argv[0] << " <string>" << endl;
        return 1;
    }

    string input = argv[1];
    string hexOutput = stringToHex(input);

    cout << "Hexadecimal representation: " << hexOutput << endl;
    return 0;
}