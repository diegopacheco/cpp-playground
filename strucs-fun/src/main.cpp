#include <iostream>
using namespace std;

struct Employee{
    int id{};
    int age{};
    double wage{};
};

int main(){

    Employee joe{};
    joe.id = 1;
    joe.age = 32;
    joe.wage = 100.0;

    Employee frank{};
    frank.id = 15;
    frank.age = 28;
    frank.wage = 20.99;

    double totalWage{ joe.wage + frank.wage };
    std::cout << "Total Wage is: " << totalWage << std::endl;
 
    if (joe.wage > frank.wage)
        std::cout << "Joe makes more than Frank\n";
    else if (joe.wage < frank.wage)
        std::cout << "Joe makes less than Frank\n";
    else
        std::cout << "Joe and Frank make the same amount\n";

    return 0;
}
