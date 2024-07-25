#include <iostream> 
#include <ranges> 
#include <vector> 
  
int main() { 
    std::vector<int> nums = { 1, 2, 3, 4, 5 }; 
    auto even_nums = nums | std::views::filter([](int n) { 
                         return n % 2 == 0; 
                     }); 
    for (auto num : even_nums) { 
        std::cout << num << " "; 
    } 
}