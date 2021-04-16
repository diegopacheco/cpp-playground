#include <iostream>
using namespace std;
#include <sstream>

static string floatToString(float *f){
    std::ostringstream ss;
    ss << f;
    std::string s(ss.str());
    return s;
}

int main(){
    
    float *ptr { 0 };  // ptr is now a null pointer
    float *ptr2; // ptr2 is uninitialized
    ptr2 = 0; // ptr2 is now a null pointer

    // pointers convert to boolean false if they are null, and boolean true if they are non-null
    if (ptr){
        std::cout << "ptr is pointing to a double value.";
    }else{
        std::cout << "ptr is a null pointer.";
    }

    float anwser = 42.0;
    ptr = &anwser;
    cout << "\nPointer: " + floatToString(ptr);
    return 0;
}
