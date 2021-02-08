#include <iostream>
#include <redis-cpp/stream.h>
#include <redis-cpp/execute.h>
using namespace std;

int main(){
    auto stream = rediscpp::make_stream("localhost", "6379");   
    std::cout << rediscpp::execute(*stream, "ping").as<std::string>() << std::endl;
    return 0;
}
