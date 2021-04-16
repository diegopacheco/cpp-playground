#include <iostream>
#include <string>
using namespace std;

int main(){
    unsigned maxguess(0);
    string hidden("concealed");
    string answer("*********");
    char guess;
    do{
        cout << "Uncovered: >>" << answer; 
        cout << "<< Your guess pls: "; 
        cin >> guess;
        for(int i = 0; i < hidden.length(); i++){
            if (guess == hidden[i])
                answer[i] = guess;
        }
    } while (++maxguess < 7);
    cout << "Game over: >>" << answer << "<<";
}