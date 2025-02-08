#include <iostream>
#include <chrono>
#include <thread>

class TokenBucket {
public:
    TokenBucket(int capacity, int refillRate)
        : capacity(capacity), refillRate(refillRate), tokens(capacity) {
        lastRefillTime = std::chrono::steady_clock::now();
    }

    bool consume(int amount) {
        refill();
        if (tokens >= amount) {
            tokens -= amount;
            std::cout << "Consumed " << amount << " tokens. Tokens left: " << tokens << '\n';
            return true;
        } else {
            std::cout << "Not enough tokens. Tokens left: " << tokens << '\n';
            return false;
        }
    }

private:
    int capacity;
    int refillRate;
    int tokens;
    std::chrono::steady_clock::time_point lastRefillTime;

    void refill() {
        auto now = std::chrono::steady_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::seconds>(now - lastRefillTime).count();
        int newTokens = duration * refillRate;
        if (newTokens > 0) {
            tokens = std::min(capacity, tokens + newTokens);
            lastRefillTime = now;
            std::cout << "Refilled " << newTokens << " tokens. Tokens now: " << tokens << '\n';
        }
    }
};

int main() {
    TokenBucket bucket(10, 1); // Capacity of 10 tokens, refills 1 token per second

    bucket.consume(5);
    std::this_thread::sleep_for(std::chrono::seconds(3));
    bucket.consume(3);
    std::this_thread::sleep_for(std::chrono::seconds(2));
    bucket.consume(4);
    std::this_thread::sleep_for(std::chrono::seconds(5));
    bucket.consume(2);

    return 0;
}