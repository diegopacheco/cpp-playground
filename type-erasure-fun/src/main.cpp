#include <iostream>
using namespace std;

class A { 
    public:
        void Print() { std::cout << "in base class" << std::endl; }
};
 
class B{
    public:
        void Print() { std::cout << "in base class" << std::endl; }
};
 
class C{
    public:
        void Print() { std::cout << "in base class" << std::endl; }
};
 
template <typename T>
void Display(T const t){
    t.Print();
}
 
int main(int argc, char **argv){
    A a;
    B b;
    C c;
 
    Display(a);   // instantiates Display<A>
    Display(b);   // instantiates Display<B>
    Display(c);   // instantiates Display<C>
 
    return 0;
}