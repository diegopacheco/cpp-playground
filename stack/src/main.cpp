#include <iostream>
#include <vector>

template <typename T>
class SimpleStack {
public:
    void push(const T& value) {
        data.push_back(value);
    }

    void pop() {
        if (!data.empty()) {
            data.pop_back();
        } else {
            std::cerr << "Stack is empty, cannot pop.\n";
        }
    }

    T top() const {
        if (!data.empty()) {
            return data.back();
        } else {
            throw std::out_of_range("Stack is empty.");
        }
    }

    bool isEmpty() const {
        return data.empty();
    }

    size_t size() const {
        return data.size();
    }

private:
    std::vector<T> data;
};

int main() {
    SimpleStack<int> stack;

    stack.push(1);
    stack.push(2);
    stack.push(3);

    std::cout << "Top element: " << stack.top() << '\n';
    std::cout << "Stack size: " << stack.size() << '\n';

    stack.pop();
    std::cout << "Top element after pop: " << stack.top() << '\n';
    std::cout << "Stack size after pop: " << stack.size() << '\n';

    stack.pop();
    stack.pop();

    if (stack.isEmpty()) {
        std::cout << "Stack is empty.\n";
    }

    return 0;
}