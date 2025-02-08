#include <iostream>
#include <vector>

template <typename T>
class SimpleQueue {
public:
    void enqueue(const T& value) {
        data.push_back(value);
    }

    void dequeue() {
        if (!data.empty()) {
            data.erase(data.begin());
        } else {
            std::cerr << "Queue is empty, cannot dequeue.\n";
        }
    }

    T front() const {
        if (!data.empty()) {
            return data.front();
        } else {
            throw std::out_of_range("Queue is empty.");
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
    SimpleQueue<int> queue;

    queue.enqueue(1);
    queue.enqueue(2);
    queue.enqueue(3);

    std::cout << "Front element: " << queue.front() << '\n';
    std::cout << "Queue size: " << queue.size() << '\n';

    queue.dequeue();
    std::cout << "Front element after dequeue: " << queue.front() << '\n';
    std::cout << "Queue size after dequeue: " << queue.size() << '\n';

    queue.dequeue();
    queue.dequeue();

    if (queue.isEmpty()) {
        std::cout << "Queue is empty.\n";
    }

    return 0;
}