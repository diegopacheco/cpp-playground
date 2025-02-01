#include <iostream>
#include <sstream>
#include <string>
#include <vector>

using namespace std;

string hex_to_string(const string& hex) {
    string result;
    for (size_t i = 0; i < hex.length(); i += 2) {
        string byte = hex.substr(i, 2);
        char chr = (char)(int)strtol(byte.c_str(), nullptr, 16);
        result.push_back(chr);
    }
    return result;
}

string add_spaces(const string& hex) {
    string spaced_hex;
    for (size_t i = 0; i < hex.length(); i += 2) {
        spaced_hex += hex.substr(i, 2) + " ";
    }
    return spaced_hex;
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        cout << "Usage: " << argv[0] << " <hex_string>" << endl;
        return 1;
    }

    string hex_string = argv[1];
    string result = hex_to_string(hex_string);
    cout << "Hex: " << add_spaces(hex_string) << endl;
    cout << "String: " << result << endl;
    return 0;
}