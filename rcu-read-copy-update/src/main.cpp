#include <iostream>
#include <thread>
#include <vector>
#include <atomic>
#include <memory>

std::atomic<int*> data(new int(0));

void reader(int id) {
    int* local_data = data.load();
    std::cout << "Reader " << id << " reads " << *local_data << '\n';
}

void writer(int new_value) {
    int* new_data = new int(new_value);
    int* old_data = data.exchange(new_data);
    delete old_data;
}

int main() {
    const int num_threads = 5;
    std::vector<std::thread> threads;

    // Start reader threads
    for (int i = 0; i < num_threads; ++i) {
        threads.emplace_back(reader, i);
    }

    // Start writer thread
    std::thread writer_thread(writer, 42);

    // Join all threads
    for (auto& t : threads) {
        t.join();
    }
    writer_thread.join();

    // Clean up
    delete data.load();

    return 0;
}