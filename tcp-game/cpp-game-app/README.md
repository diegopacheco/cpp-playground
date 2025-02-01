# C++ Game Application

This project is a simple client/server application implemented in C++ using sockets. The game allows clients to register with a name and guess a number, with the first user to guess the correct number winning.

## Project Structure

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

## Building the Project

To build the project, follow these steps:

1. Ensure you have CMake installed on your system.
2. Open a terminal and navigate to the project directory.
3. Create a build directory:
   ```
   mkdir build
   cd build
   ```
4. Run CMake to configure the project:
   ```
   cmake ..
   ```
5. Compile the project:
   ```
   make
   ```

## Running the Application

1. Start the server:
   ```
   ./server
   ```
2. In a new terminal, start the client:
   ```
   ./client
   ```

## Game Rules

- Each client must register with a unique name.
- Clients take turns guessing a number.
- The server randomly selects a number, and the first client to guess it correctly wins.
- The server will notify all clients of the result after each guess.

## Dependencies

- C++11 or higher
- POSIX compliant system for socket programming

## License

This project is licensed under the MIT License. See the LICENSE file for details.