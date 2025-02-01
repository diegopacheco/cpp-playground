cmake_minimum_required(VERSION 3.29)

# Set the project name
project(CPPGameApp)

# Set the C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Add the executable for the server
add_executable(server src/server.cpp src/common/utils.cpp)

# Add the executable for the client
add_executable(client src/client.cpp src/common/utils.cpp)