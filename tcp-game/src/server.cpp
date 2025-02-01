#include <iostream>
#include <string>
#include <cstdlib>
#include <ctime>
#include <unistd.h>
#include <arpa/inet.h>
#include <vector>
#include <thread>

using namespace std;

const int PORT = 8080;
const int MAX_CLIENTS = 10;

struct Client {
    int socket;
    string name;
};

vector<Client> clients;
int secretNumber;

void broadcast(const string& message) {
    for (const auto& client : clients) {
        send(client.socket, message.c_str(), message.size(), 0);
    }
}

void handleClient(Client client) {
    char buffer[1024];
    int bytesRead;

    while ((bytesRead = recv(client.socket, buffer, sizeof(buffer), 0)) > 0) {
        buffer[bytesRead] = '\0';
        try {
            int guess = stoi(buffer);
            if (guess == secretNumber) {
                string winMessage = client.name + " has guessed the correct number: " + to_string(secretNumber) + "\n";
                broadcast(winMessage);
                break;
            } else {
                string message = "";
                if (guess < secretNumber) {
                    message = "The secret number is greater than " + to_string(guess) + "\n";
                } else {
                    message = "The secret number is less than " + to_string(guess) + "\n";
                }
                send(client.socket, message.c_str(), message.size(), 0);
            }
        } catch (const invalid_argument& e) {
            string errorMessage = "Invalid input, please enter a number.\n";
            send(client.socket, errorMessage.c_str(), errorMessage.size(), 0);
        }
    }

    close(client.socket);
}

int main() {
    srand(time(0));
    secretNumber = rand() % 100 + 1;

    int serverSocket, clientSocket;
    struct sockaddr_in serverAddr, clientAddr;
    socklen_t clientAddrLen = sizeof(clientAddr);

    serverSocket = socket(AF_INET, SOCK_STREAM, 0);
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_addr.s_addr = INADDR_ANY;
    serverAddr.sin_port = htons(PORT);

    bind(serverSocket, (struct sockaddr*)&serverAddr, sizeof(serverAddr));
    listen(serverSocket, MAX_CLIENTS);

    cout << "Server is listening on port " << PORT << endl;

    while (true) {
        clientSocket = accept(serverSocket, (struct sockaddr*)&clientAddr, &clientAddrLen);
        char nameBuffer[1024];
        recv(clientSocket, nameBuffer, sizeof(nameBuffer), 0);
        string clientName = nameBuffer;

        Client client = {clientSocket, clientName};
        clients.push_back(client);
        cout << "Client connected: " << clientName << endl;

        thread(handleClient, client).detach();
    }

    close(serverSocket);
    return 0;
}