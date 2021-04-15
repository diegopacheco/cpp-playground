#include <iostream>
using namespace std;

class Printer {
  public:    
    Printer(){
      cout << "Creating Printer object. " << endl;  
    }          
    void print(string msg) {
      cout << msg << endl;
    }
};

int main(){
    Printer printer = Printer();
    printer.print("Hi cpp!");
    return 0;
}
