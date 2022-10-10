#include <iostream>
#include <fstream>
using namespace std;

int main()
{
    std::ofstream output("target/example.txt");
    cout << "The answer to life, the universe, and everything is ";
    output << 42;
    output.close();

    std::string filename{"target/example.txt"};
    std::ifstream input{filename};

    if (!input.is_open()){
        std::cerr << "Couldn't read file: " << filename << "\n";
        return 1;
    }

    int number = 0;
    input >> number;
    std::cout << "The number is " << number << ".\n";
}
