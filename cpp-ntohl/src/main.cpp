#include <iostream>
#include <arpa/inet.h>

int main() {
    uint32_t netOrder = 0x12345678; // network byte value
    uint32_t hostOrder = ntohl(netOrder);

    std::cout << "Network byte order: 0x" << std::hex << netOrder << std::endl;
    std::cout << "Host byte order: 0x" << std::hex << hostOrder << std::endl;
    std::cout << "Network byte order: " << std::to_string(netOrder) << std::endl;
    std::cout << "Host byte order: " << std::to_string(hostOrder) << std::endl;
    return 0;
}