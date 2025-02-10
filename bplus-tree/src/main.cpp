#include <iostream>
#include <vector>
#include <algorithm>

const int MAX_KEYS = 3;

class BPlusTreeNode {
public:
    bool isLeaf;
    std::vector<int> keys;
    std::vector<BPlusTreeNode*> children;
    BPlusTreeNode* next;
    BPlusTreeNode(bool isLeaf) : isLeaf(isLeaf), next(nullptr) {}
};

class BPlusTree {
public:
    BPlusTree() : root(nullptr) {}

    void insert(int key) {
        if (root == nullptr) {
            root = new BPlusTreeNode(true);
            root->keys.push_back(key);
            return;
        }

        insertInternal(root, key);
    }

    void printTree() {
        printTreeInternal(root, 0);
    }

private:
    BPlusTreeNode* root;

    void insertInternal(BPlusTreeNode* node, int key) {
        if (node->isLeaf) {
            insertIntoLeaf(node, key);
        } else {
            int i = 0;
            while (i < node->keys.size() && key > node->keys[i]) {
                i++;
            }
            insertInternal(node->children[i], key);
        }

        if (node->keys.size() > MAX_KEYS) {
            splitNode(node);
        }
    }

    void insertIntoLeaf(BPlusTreeNode* leaf, int key) {
        auto it = std::lower_bound(leaf->keys.begin(), leaf->keys.end(), key);
        leaf->keys.insert(it, key);
    }

    void splitNode(BPlusTreeNode* node) {
        int mid = (MAX_KEYS + 1) / 2;
        BPlusTreeNode* newNode = new BPlusTreeNode(node->isLeaf);

        // Split keys
        newNode->keys.assign(node->keys.begin() + mid, node->keys.end());
        node->keys.erase(node->keys.begin() + mid, node->keys.end());

        if (!node->isLeaf) {
            // Split children
            newNode->children.assign(node->children.begin() + mid + 1, node->children.end());
            node->children.erase(node->children.begin() + mid + 1, node->children.end());
        } else {
            // Link leaf nodes
            newNode->next = node->next;
            node->next = newNode;
        }

        int splitKey = newNode->keys[0];
        insertKeyIntoParent(node, splitKey, newNode);
    }

    void insertKeyIntoParent(BPlusTreeNode* child, int key, BPlusTreeNode* newChild) {
        if (child == root) {
            BPlusTreeNode* newRoot = new BPlusTreeNode(false);
            newRoot->keys.push_back(key);
            newRoot->children.push_back(child);
            newRoot->children.push_back(newChild);
            root = newRoot;
            return;
        }

        BPlusTreeNode* parent = findParent(root, child);
        if (parent == nullptr) return;

        auto it = std::lower_bound(parent->keys.begin(), parent->keys.end(), key);
        int index = std::distance(parent->keys.begin(), it);

        parent->keys.insert(it, key);
        parent->children.insert(parent->children.begin() + index + 1, newChild);
    }

    BPlusTreeNode* findParent(BPlusTreeNode* node, BPlusTreeNode* child) {
        if (node == nullptr || node->isLeaf) return nullptr;

        for (BPlusTreeNode* n : node->children) {
            if (n == child) return node;
        }

        for (BPlusTreeNode* n : node->children) {
            BPlusTreeNode* found = findParent(n, child);
            if (found != nullptr) return found;
        }

        return nullptr;
    }

    void printTreeInternal(BPlusTreeNode* node, int level) {
        if (node == nullptr) return;

        std::cout << "Level " << level << ": ";
        for (int key : node->keys) {
            std::cout << key << " ";
        }
        std::cout << std::endl;

        if (!node->isLeaf) {
            for (BPlusTreeNode* child : node->children) {
                printTreeInternal(child, level + 1);
            }
        }
    }
};

int main() {
    BPlusTree tree;
    tree.insert(10);
    tree.insert(20);
    tree.insert(30);
    tree.insert(40);
    tree.insert(50);
    tree.insert(60);
    tree.insert(70);

    tree.printTree();
    return 0;
}