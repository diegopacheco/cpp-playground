#include <iostream>
#include <string>
#include <unistd.h>
#include <arpa/inet.h>

using namespace std;

const int PORT = 8080;

int main() {
    int sock = 0;
    struct sockaddr_in serv_addr;

    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        cout << "Socket creation error" << endl;
        return -1;
    }

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(PORT);

    if (inet_pton(AF_INET, "127.0.0.1", &serv_addr.sin_addr) <= 0) {
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
    char buffer[1024] = {0}; // Declare buffer only once
    while (true) {
        cout << "Guess a number (1-100): ";
        cin >> guess;
        string guessStr = to_string(guess);
        send(sock, guessStr.c_str(), guessStr.size(), 0);

        // Receive result from server
        int bytesRead = recv(sock, buffer, sizeof(buffer), 0);
        if (bytesRead > 0) {
            buffer[bytesRead] = '\0';
            string result(buffer);

            if (result.find("Congratulations") != string::npos) {
                cout << result << endl;
                break;
            } else {
                cout << result << endl;
            }
        }
    }

    close(sock);
    return 0;
}