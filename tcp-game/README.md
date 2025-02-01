### C++ Game Application

This project is a simple client/server application implemented in C++ using sockets. The game allows clients to register with a name and guess a number, with the first user to guess the correct number winning.

### Code Structure

```
cpp-game-app
├── src
│   ├── client.cpp        # client impl
│   ├── server.cpp        # game server impl
│   └── common
│       └── utils.cpp     # shared code between client and server
│       └── utils.h       # 
├── CMakeLists.txt        # CMake build file
├── README.md             # README
└── build.sh              # build script
```

### Buid

```bash
./build.sh
```

### Run

Server

```bash
./build/server
```

```
❯ ./target/server
Server is listening on port 8080
Client connected: diego
Client connected: john
```

Client

```bash
./build/client
```

```
❯ ./target/client
Enter your name: diego
Guess a number (1-100): 100
The secret number is less than 100

Guess a number (1-100): 50
The secret number is less than 50

Guess a number (1-100): 40
The secret number is less than 40

Guess a number (1-100): 10
The secret number is greater than 10

Guess a number (1-100): 20
The secret number is less than 20

Guess a number (1-100): 15
The secret number is less than 15

Guess a number (1-100): 12
The secret number is greater than 12

Guess a number (1-100): 13
The secret number is greater than 13

Guess a number (1-100): 14
diego has guessed the correct number: 14 
```