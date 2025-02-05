#include <iostream>
#include <thread>
#include <condition_variable>

int main() {
    bool ready = false;
    std::mutex m;
    std::condition_variable cv;
    std::thread worker([&] {
        std::unique_lock<std::mutex> lock(m);
        cv.wait(lock, [&]{return ready;});
        std::cout << "Worker done\n";
    });
    
    {
        std::lock_guard<std::mutex> lock(m);
        ready = true;
    }

    cv.notify_one();
    worker.join();
    return 0;
}