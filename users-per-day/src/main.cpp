#include <iostream>
#include <string>
#include <iomanip>
using namespace std;

int user_per_day(int user_per_minute);

string format_number(long number) {
    string num_str = to_string(number);
    int n = num_str.length();
    int pos = n - 3;
    while (pos > 0) {
        num_str.insert(pos, ",");
        pos -= 3;
    }
    return num_str;
}

int main(){
    for (int i = 0; i <= 100; i++){
        auto rps = i * 100;
        cout << format_number(rps) << " RPS = " << format_number(user_per_day(rps)) << " users per day" << endl;
    }
    return 0;
}

int user_per_day(int user_per_minute){
    auto users = user_per_minute * (60 * 24);
    return users;
}