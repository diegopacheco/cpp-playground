#include <iostream>
#include <vector>
#include <algorithm>

class MaxHeap {
public:
    MaxHeap() {}

    void insert(int value) {
        heap.push_back(value);
        int i = heap.size() - 1;
        while (i != 0 && heap[parent(i)] < heap[i]) {
            std::swap(heap[i], heap[parent(i)]);
            i = parent(i);
        }
    }

    int extractMax() {
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
        maxHeapify(0);

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

    void maxHeapify(int i) {
        int l = left(i);
        int r = right(i);
        int largest = i;
        if (l < heap.size() && heap[l] > heap[i]) {
            largest = l;
        }
        if (r < heap.size() && heap[r] > heap[largest]) {
            largest = r;
        }
        if (largest != i) {
            std::swap(heap[i], heap[largest]);
            maxHeapify(largest);
        }
    }
};

int main() {
    MaxHeap maxHeap;
    maxHeap.insert(3);
    maxHeap.insert(1);
    maxHeap.insert(4);
    maxHeap.insert(1);
    maxHeap.insert(5);
    maxHeap.insert(9);
    maxHeap.insert(2);
    maxHeap.insert(6);

    std::cout << "Max Heap: ";
    maxHeap.printHeap();

    std::cout << "Extract Max: " << maxHeap.extractMax() << std::endl;
    std::cout << "Heap after extractMax: ";
    maxHeap.printHeap();

    return 0;
}