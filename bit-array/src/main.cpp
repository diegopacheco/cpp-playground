#include <iostream>
#include <vector>
using namespace std;

class BitArray {

 private:
    size_t size;
    std::vector<unsigned int> data;
    size_t numElements;
    static const size_t bitsPerElement = sizeof(unsigned int) * 8;

 public:
    BitArray(size_t size) : size(size) {
        // Calculate the number of elements needed in the vector
        numElements = (size + bitsPerElement - 1) / bitsPerElement;
        data.resize(numElements, 0);
    }

    void set(size_t index) {
        if (index >= size) {
            std::cerr << "Index out of bounds.\n";
            return;
        }

        size_t elementIndex = index / bitsPerElement;
        size_t bitIndex = index % bitsPerElement;
        data[elementIndex] |= (1 << bitIndex);
    }

    void clear(size_t index) {
        if (index >= size) {
            std::cerr << "Index out of bounds.\n";
            return;
        }

        size_t elementIndex = index / bitsPerElement;
        size_t bitIndex = index % bitsPerElement;
        data[elementIndex] &= ~(1 << bitIndex);
    }

    bool get(size_t index) const {
        if (index >= size) {
            std::cerr << "Index out of bounds.\n";
            return false;
        }

        size_t elementIndex = index / bitsPerElement;
        size_t bitIndex = index % bitsPerElement;
        return (data[elementIndex] & (1 << bitIndex)) != 0;
    }

};

int main() {
    BitArray bitArray(100);

    bitArray.set(10);
    bitArray.set(50);
    bitArray.set(99);

    std::cout << "Bit at index 10: " << bitArray.get(10) << std::endl; // 1
    std::cout << "Bit at index 20: " << bitArray.get(20) << std::endl; // 0
    std::cout << "Bit at index 50: " << bitArray.get(50) << std::endl; // 1
    std::cout << "Bit at index 99: " << bitArray.get(99) << std::endl; // 1

    bitArray.clear(50);
    std::cout << "Bit at index 50 after clear: " << bitArray.get(50) << std::endl; // 0

    return 0;
}