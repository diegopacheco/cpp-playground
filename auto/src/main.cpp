#include <iostream>
#include <vector>
using namespace std;

int main() {
    // Basic usage: Deduce the type of an integer
    auto number = 10;
    cout << "The number is: " << number << endl;

    // Deduce the type of a double
    auto pi = 3.14159;
    cout << "The value of pi is: " << pi << endl;

    // Deduce the type of a string
    // message is const char*
    auto message = "Hello, auto!"; 
    cout << message << endl;

    // Using auto with iterators
    vector<int> numbers = {1, 2, 3, 4, 5};
    for (auto it = numbers.begin(); it != numbers.end(); ++it) {
        cout << *it << " "; // it is deduced to be std::vector<int>::iterator
    }
    cout << endl;

    // Using auto with range-based for loops (C++11 and later)
    // num is deduced to be int
    for (auto num : numbers) {
        cout << num << " ";
    }
    cout << endl;

    // Using auto to deduce return types 
    // (C++14 and later, but generally discouraged for complex functions)
    // add is deduced to be a lambda function that takes two ints and returns an int
    auto add = [](int a, int b) { return a + b; }; 
    cout << "5 + 3 = " << add(5, 3) << endl;

    // Auto with structured bindings (C++17 and later)
    // intVal is int, doubleVal is double
    std::pair<int, double> myPair = {10, 3.14};
    auto [intVal, doubleVal] = myPair; 
    cout << "Int value: " << intVal << ", Double value: " << doubleVal << endl;

    return 0;
}