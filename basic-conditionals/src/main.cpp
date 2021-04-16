#include <iostream>
using namespace std;

int main(){
    int time = 20;
    string result = (time < 18) ? "Good day." : "Good evening.";
    cout << result;

    cout << "\n";
    time = 16;
    if (time < 18) {
        cout << "Good day.";
    } else {
        cout << "Good evening.";
    }            

    return 0;
}
