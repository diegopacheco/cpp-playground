#include <iostream>
using namespace std;

void funWithWhile(){
    cout << "Fun with While:" << endl;
    int i = 0;
    while (i < 10){
        cout << i << "\n";
        i++;
    }
}

void funWithFor(){
    cout << "Fun with For:" << endl;
    for (int i = 0; i < 10; i++) {
        cout << i << "\n";
    }
}

int main(){
    funWithWhile();    
    funWithFor();
    return 0;
}
