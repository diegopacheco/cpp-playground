#include <iostream>
#include <fstream>
#include <jsoncpp/json/json.h>

using namespace std;

int main(){
    ifstream ifs("data.json");
    Json::Reader reader;
    Json::Value obj;
    reader.parse(ifs,obj);
    cout << "Json C++ in action: " << endl;
    cout << "> Lastname " << obj["lastname"].asString() << endl;
    cout << "> Firstname " << obj["firstname"].asString() << endl;
    return 1;
}