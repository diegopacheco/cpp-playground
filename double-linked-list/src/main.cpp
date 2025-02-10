#include <iostream>

template <typename T>
class DoublyLinkedList {
private:
    struct Node {
        T data;
        Node* next;
        Node* prev;

        Node(const T& value) : data(value), next(nullptr), prev(nullptr) {}
    };

    Node* head;
    Node* tail;
    size_t count;

public:
    DoublyLinkedList() : head(nullptr), tail(nullptr), count(0) {}

    ~DoublyLinkedList() {
        Node* current = head;
        while (current != nullptr) {
            Node* next = current->next;
            delete current;
            current = next;
        }
    }

    void append(const T& value) {
        Node* newNode = new Node(value);
        if (head == nullptr) {
            head = newNode;
            tail = newNode;
        } else {
            tail->next = newNode;
            newNode->prev = tail;
            tail = newNode;
        }
        count++;
    }

    void prepend(const T& value) {
        Node* newNode = new Node(value);
        if (head == nullptr) {
            head = newNode;
            tail = newNode;
        } else {
            newNode->next = head;
            head->prev = newNode;
            head = newNode;
        }
        count++;
    }

    void insertAt(size_t index, const T& value) {
        if (index > count) {
            std::cerr << "Index out of bounds.\n";
            return;
        }

        if (index == 0) {
            prepend(value);
        } else if (index == count) {
            append(value);
        } else {
            Node* newNode = new Node(value);
            Node* current = head;
            for (size_t i = 0; i < index; ++i) {
                current = current->next;
            }

            newNode->next = current;
            newNode->prev = current->prev;
            current->prev->next = newNode;
            current->prev = newNode;
            count++;
        }
    }

    void removeAt(size_t index) {
        if (index >= count) {
            std::cerr << "Index out of bounds.\n";
            return;
        }

        if (index == 0) {
            Node* temp = head;
            head = head->next;
            if (head != nullptr) {
                head->prev = nullptr;
            } else {
                tail = nullptr;
            }
            delete temp;
        } else if (index == count - 1) {
            Node* temp = tail;
            tail = tail->prev;
            tail->next = nullptr;
            delete temp;
        } else {
            Node* current = head;
            for (size_t i = 0; i < index; ++i) {
                current = current->next;
            }

            current->prev->next = current->next;
            current->next->prev = current->prev;
            delete current;
        }
        count--;
    }

    T get(size_t index) const {
        if (index >= count) {
            throw std::out_of_range("Index out of bounds.");
        }

        Node* current = head;
        for (size_t i = 0; i < index; ++i) {
            current = current->next;
        }
        return current->data;
    }

    size_t size() const {
        return count;
    }

    bool isEmpty() const {
        return count == 0;
    }

    void printList() const {
        Node* current = head;
        while (current != nullptr) {
            std::cout << current->data << " ";
            current = current->next;
        }
        std::cout << std::endl;
    }
};

int main() {
    DoublyLinkedList<int> list;
    list.append(1);
    list.append(2);
    list.append(3);

    std::cout << "List: ";
    list.printList();

    list.prepend(0);
    std::cout << "List after prepend: ";
    list.printList();

    list.insertAt(2, 5);
    std::cout << "List after insertAt: ";
    list.printList();

    list.removeAt(1);
    std::cout << "List after removeAt: ";
    list.printList();

    std::cout << "Element at index 1: " << list.get(1) << std::endl;
    std::cout << "Size: " << list.size() << std::endl;

    return 0;
}