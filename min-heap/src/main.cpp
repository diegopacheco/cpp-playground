#include <iostream>
#include <vector>
#include <algorithm>

class MinHeap {
public:
    MinHeap() {}

    void insert(int value) {
        heap.push_back(value);
        int i = heap.size() - 1;
        while (i != 0 && heap[parent(i)] > heap[i]) {
            std::swap(heap[i], heap[parent(i)]);
            i = parent(i);
        }
    }

    int extractMin() {
        if (heap.empty()) {
            std::cerr << "Heap is empty.\n";
            return -1;
        }
        if (heap.size() == 1) {
            int root = heap[0];
            heap.erase(heap.begin());
            return root;
        }

        int root = heap[0];
        heap[0] = heap.back();
        heap.pop_back();
        minHeapify(0);

        return root;
    }

    void printHeap() const {
        for (int value : heap) {
            std::cout << value << " ";
        }
        std::cout << std::endl;
    }

private:
    std::vector<int> heap;

    int parent(int i) {
        return (i - 1) / 2;
    }

    int left(int i) {
        return (2 * i + 1);
    }

    int right(int i) {
        return (2 * i + 2);
    }

    void minHeapify(int i) {
        int l = left(i);
        int r = right(i);
        int smallest = i;
        if (l < heap.size() && heap[l] < heap[i]) {
            smallest = l;
        }
        if (r < heap.size() && heap[r] < heap[smallest]) {
            smallest = r;
        }
        if (smallest != i) {
            std::swap(heap[i], heap[smallest]);
            minHeapify(smallest);
        }
    }
};

int main() {
    MinHeap minHeap;
    minHeap.insert(3);
    minHeap.insert(1);
    minHeap.insert(4);
    minHeap.insert(1);
    minHeap.insert(5);
    minHeap.insert(9);
    minHeap.insert(2);
    minHeap.insert(6);

    std::cout << "Min Heap: ";
    minHeap.printHeap();

    std::cout << "Extract Min: " << minHeap.extractMin() << std::endl;
    std::cout << "Heap after extractMin: ";
    minHeap.printHeap();

    return 0;
}