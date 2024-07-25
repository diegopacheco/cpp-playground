#include <iostream>
using namespace std;

template<typename T>
concept Addable = requires(T a, T b) {
  { a + b } -> std::convertible_to<T>;
};

template<Addable T>
T add(T a, T b) {
  return a + b;
}

int main(){
    cout << add(1, 2) << endl;
    cout << add(1.1, 2.2) << endl;
    cout << add(1.1f, 2.2f) << endl;
    cout << add('a', 'b') << endl;
    cout << add(string("Hello"), string("World")) << endl;
    return 0;
}
