#include <iostream>
#include <vector>
#include <random>

const double P = 0.5;       // Probability of a node having a higher level
const int MAX_LEVEL = 16;

struct SkipNode {
    int key;
    std::vector<SkipNode*> forward;

    SkipNode(int key, int level) : key(key), forward(level + 1, nullptr) {}
};

class SkipList {
public:
    SkipList() : level(0) {
        // Head node with dummy key
        head = new SkipNode(-1, MAX_LEVEL);
    }

    ~SkipList() {
        SkipNode* node = head;
        while (node != nullptr) {
            SkipNode* next = node->forward[0];
            delete node;
            node = next;
        }
    }

    void insert(int key) {
        std::vector<SkipNode*> update(MAX_LEVEL + 1, nullptr);
        SkipNode* current = head;

        for (int i = level; i >= 0; --i) {
            while (current->forward[i] != nullptr && current->forward[i]->key < key) {
                current = current->forward[i];
            }
            update[i] = current;
        }

        int newLevel = randomLevel();
        if (newLevel > level) {
            for (int i = level + 1; i <= newLevel; ++i) {
                update[i] = head;
            }
            level = newLevel;
        }

        SkipNode* newNode = new SkipNode(key, newLevel);
        for (int i = 0; i <= newLevel; ++i) {
            newNode->forward[i] = update[i]->forward[i];
            update[i]->forward[i] = newNode;
        }
    }

    bool search(int key) {
        SkipNode* current = head;
        for (int i = level; i >= 0; --i) {
            while (current->forward[i] != nullptr && current->forward[i]->key < key) {
                current = current->forward[i];
            }
        }

        if (current->forward[0] != nullptr && current->forward[0]->key == key) {
            return true;
        } else {
            return false;
        }
    }

    void erase(int key) {
        std::vector<SkipNode*> update(MAX_LEVEL + 1, nullptr);
        SkipNode* current = head;

        for (int i = level; i >= 0; --i) {
            while (current->forward[i] != nullptr && current->forward[i]->key < key) {
                current = current->forward[i];
            }
            update[i] = current;
        }

        if (current->forward[0] != nullptr && current->forward[0]->key == key) {
            SkipNode* toDelete = current->forward[0];
            for (int i = 0; i <= level && update[i]->forward[i] == toDelete; ++i) {
                update[i]->forward[i] = toDelete->forward[i];
            }

            delete toDelete;

            while (level > 0 && head->forward[level] == nullptr) {
                level--;
            }
        }
    }

    void printList() const {
        std::cout << "Skip List: ";
        SkipNode* node = head->forward[0];
        while (node != nullptr) {
            std::cout << node->key << " ";
            node = node->forward[0];
        }
        std::cout << std::endl;
    }

private:
    SkipNode* head;
    int level;

    int randomLevel() {
        int lvl = 0;
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_real_distribution<> dis(0.0, 1.0);

        while (dis(gen) < P && lvl < MAX_LEVEL) {
            lvl++;
        }
        return lvl;
    }
};

int main() {
    SkipList skipList;
    skipList.insert(3);
    skipList.insert(6);
    skipList.insert(7);
    skipList.insert(9);
    skipList.insert(12);
    skipList.insert(19);
    skipList.insert(17);
    skipList.insert(26);
    skipList.insert(21);
    skipList.insert(25);

    std::cout << "Skip List after insertions:\n";
    skipList.printList();

    std::cout << "Search 12: " << skipList.search(12) << std::endl;
    std::cout << "Search 15: " << skipList.search(15) << std::endl;

    skipList.erase(12);
    std::cout << "Skip List after deleting 12:\n";
    skipList.printList();

    return 0;
}