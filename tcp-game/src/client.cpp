#include <iostream>
#include <string>
#include <cstring>
#include <cstdlib>
#include <unistd.h>
#include <arpa/inet.h>

using namespace std;

const int PORT = 8080;
const char* SERVER_IP = "127.0.0.1";

int main() {
    int sock = 0;
    struct sockaddr_in serv_addr;
    char buffer[1024] = {0};

    // Create socket
    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        cout << "Socket creation error" << endl;
        return -1;
    }

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(PORT);

    // Convert IPv4 and IPv6 addresses from text to binary form
    if (inet_pton(AF_INET, SERVER_IP, &serv_addr.sin_addr) <= 0) {
        cout << "Invalid address/ Address not supported" << endl;
        return -1;
    }

    // Connect to server
    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
        cout << "Connection failed" << endl;
        return -1;
    }

    string name;
    cout << "Enter your name: ";
    getline(cin, name);
    send(sock, name.c_str(), name.size(), 0);

    int guess;
    while (true) {
        cout << "Guess a number (1-100): ";
        cin >> guess;
        send(sock, &guess, sizeof(guess), 0);
        
        // Receive result from server
        int result;
        recv(sock, &result, sizeof(result), 0);
        
        if (result == 1) {
            cout << "Congratulations! You guessed the correct number!" << endl;
            break;
        } else {
            cout << "Wrong guess, try again!" << endl;
        }
    }

    close(sock);
    return 0;
}