#include <iostream>
#include <iostream>
#include <fstream>
using namespace std;

int main(){
    string filePath = "target/log.txt";    
    ofstream MyFile(filePath);
    MyFile << "Files can be tricky, but it is fun enough!";
    MyFile.close();
    cout << "DONE File was written." << endl;

    cout << "Reading [" << filePath << "]" << endl;
    string myText;
    ifstream MyReadFile(filePath);
    while (getline(MyReadFile, myText)){
        cout << myText;
    }
    MyReadFile.close();

    return 0;
}
