#include <iostream>
using namespace std;

class A {
private:
    int answer; 
public:
    A(){ 
        answer = 42; 
    }
    friend class B;
};
 
class B {
public:
    void showA(A& x){
        // Since B is friend of A, it can access
        // private members of A
        std::cout << "A::answer=" << x.answer << "\n";
    }
};
 
class C {
public:
    void showA(A& x){
        // dont compile! class "C" has no member "answer"C/C++(135)
        //std::cout << "A::answer=" << x.answer;
        // dont compile! member "A::answer" (declared at line 6) is inaccessibleC/C++(265)
        //std::cout << "A::answer=" << x.answer;
        std::cout << &x;
    }
};

int main(){
    A a;
    B b;
    C c;
    b.showA(a);
    c.showA(a);
    return 0;
}