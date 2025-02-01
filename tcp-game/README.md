### C++ Game Application

This project is a simple client/server application implemented in C++ using sockets. The game allows clients to register with a name and guess a number, with the first user to guess the correct number winning.

### Code Structure

```
cpp-game-app
├── src
│   ├── client.cpp        # Client-side application implementation
│   ├── server.cpp        # Server-side application implementation
│   └── common
│       └── utils.cpp     # Utility functions implementation
│       └── utils.h       # Utility functions declarations
├── CMakeLists.txt        # CMake configuration file
└── README.md             # Project documentation
```