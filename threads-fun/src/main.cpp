#include <iostream>
#include <thread>
 
void foo() {
  std::cout << "foo called" << std::endl;
}

void bar(int x){
  std::cout << "bar called: " << x << std::endl;
}

int main() {
  std::thread first (foo);      // spawn new thread that calls foo()
  std::thread second (bar,42);  // spawn new thread that calls bar(0)

  std::cout << "main, foo and bar now execute concurrently...\n";

  // synchronize threads:
  first.join();                // pauses until first finishes
  second.join();               // pauses until second finishes

  std::cout << "foo and bar completed.\n";
  return 0;
}