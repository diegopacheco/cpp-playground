#include <iostream>
#include <iostream>
#include <fstream>
using namespace std;

int main(){
    
    ofstream MyFile("target/log.txt");
    MyFile << "Files can be tricky, but it is fun enough!";
    MyFile.close();
    cout << "DONE." << endl;
    return 0;
}
