#include <iostream>
#include <string_view>
using namespace std;

enum class rgba_color_channel{
    red,
    green,
    blue,
    alpha
};

std::string_view to_string(rgba_color_channel my_channel){
    switch (my_channel){
        using enum rgba_color_channel;
    case red:
        return "red";
    case green:
        return "green";
    case blue:
        return "blue";
    case alpha:
        return "alpha";
    default:
        return "unknown";
    }
}

int main(){
    std::cout << to_string(rgba_color_channel::blue) << std::endl;
    return 0;
}
