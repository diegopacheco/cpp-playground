#include <iostream>
#include <chrono>
#include <thread>

class LeakyBucket {
public:
    LeakyBucket(int capacity, int leakRate)
        : capacity(capacity), leakRate(leakRate), currentWater(0) {
        lastLeakTime = std::chrono::steady_clock::now();
    }

    bool addWater(int amount) {
        leak();
        if (currentWater + amount > capacity) {
            std::cout << "Bucket overflow. Dropping " << amount << " units of water.\n";
            return false;
        } else {
            currentWater += amount;
            std::cout << "Added " << amount << " units of water. Current water: " << currentWater << '\n';
            return true;
        }
    }

private:
    int capacity;
    int leakRate;
    int currentWater;
    std::chrono::steady_clock::time_point lastLeakTime;

    void leak() {
        auto now = std::chrono::steady_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::seconds>(now - lastLeakTime).count();
        int leakedWater = duration * leakRate;
        if (leakedWater > 0) {
            currentWater = std::max(0, currentWater - leakedWater);
            lastLeakTime = now;
            std::cout << "Leaked " << leakedWater << " units of water. Current water: " << currentWater << '\n';
        }
    }
};

int main() {
    // Capacity of 10 units, leaks 1 unit per second
    LeakyBucket bucket(10, 1); 

    bucket.addWater(5);
    std::this_thread::sleep_for(std::chrono::seconds(3));
    bucket.addWater(3);
    std::this_thread::sleep_for(std::chrono::seconds(2));
    bucket.addWater(4);
    std::this_thread::sleep_for(std::chrono::seconds(5));
    bucket.addWater(2);

    return 0;
}