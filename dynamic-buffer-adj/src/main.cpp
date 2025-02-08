#include <iostream>
#include <queue>
#include <chrono>
#include <thread>

class DynamicBuffer {
public:
    DynamicBuffer(int initialCapacity, int maxCapacity)
        : capacity(initialCapacity), maxCapacity(maxCapacity), currentSize(0) {}

    bool addData(int amount) {
        adjustBuffer();
        if (currentSize + amount > capacity) {
            std::cout << "Buffer overflow. Dropping " << amount << " units of data.\n";
            return false;
        } else {
            buffer.push(amount);
            currentSize += amount;
            std::cout << "Added " << amount << " units of data. Current size: " << currentSize << '\n';
            return true;
        }
    }

    void processData() {
        if (!buffer.empty()) {
            int amount = buffer.front();
            buffer.pop();
            currentSize -= amount;
            std::cout << "Processed " << amount << " units of data. Current size: " << currentSize << '\n';
        }
    }

private:
    int capacity;
    int maxCapacity;
    int currentSize;
    std::queue<int> buffer;
    std::chrono::steady_clock::time_point lastAdjustTime = std::chrono::steady_clock::now();

    void adjustBuffer() {
        auto now = std::chrono::steady_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::seconds>(now - lastAdjustTime).count();
        if (duration > 0) {
            if (currentSize > capacity / 2 && capacity < maxCapacity) {
                capacity = std::min(maxCapacity, capacity * 2);
                std::cout << "Increased buffer capacity to " << capacity << '\n';
            } else if (currentSize < capacity / 4 && capacity > 1) {
                capacity = std::max(1, capacity / 2);
                std::cout << "Decreased buffer capacity to " << capacity << '\n';
            }
            lastAdjustTime = now;
        }
    }
};

int main() {
    // Initial capacity of 10, max capacity of 40
    DynamicBuffer buffer(10, 40); 

    buffer.addData(5);
    std::this_thread::sleep_for(std::chrono::seconds(1));
    buffer.addData(8);
    std::this_thread::sleep_for(std::chrono::seconds(1));
    buffer.processData();
    std::this_thread::sleep_for(std::chrono::seconds(1));
    buffer.addData(20);
    std::this_thread::sleep_for(std::chrono::seconds(1));
    buffer.processData();
    std::this_thread::sleep_for(std::chrono::seconds(1));
    buffer.addData(15);
    std::this_thread::sleep_for(std::chrono::seconds(1));
    buffer.processData();
    std::this_thread::sleep_for(std::chrono::seconds(1));
    buffer.addData(10);
    std::this_thread::sleep_for(std::chrono::seconds(1));
    buffer.processData();

    return 0;
}