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
Server is listening on port 8080
```

Client

```bash
./build/client
```

```
❯ ./client
Enter your name: diego
Guess a number (1-100): 1
Wrong guess, try again!
Guess a number (1-100): 
```