#include <iostream>
#include <string>
#include <vector>

class TrieNode {
public:
    TrieNode() : isEndOfWord(false) {
        children.resize(26, nullptr); // Assuming lowercase English letters
    }

    std::vector<TrieNode*> children;
    bool isEndOfWord;
};

class Trie {
public:
    Trie() {
        root = new TrieNode();
    }

    void insert(const std::string& word) {
        TrieNode* node = root;
        for (char c : word) {
            int index = c - 'a';
            if (!node->children[index]) {
                node->children[index] = new TrieNode();
            }
            node = node->children[index];
        }
        node->isEndOfWord = true;
    }

    bool search(const std::string& word) {
        TrieNode* node = root;
        for (char c : word) {
            int index = c - 'a';
            if (!node->children[index]) {
                return false;
            }
            node = node->children[index];
        }
        return (node != nullptr && node->isEndOfWord);
    }

    bool startsWith(const std::string& prefix) {
        TrieNode* node = root;
        for (char c : prefix) {
            int index = c - 'a';
            if (!node->children[index]) {
                return false;
            }
            node = node->children[index];
        }
        return node != nullptr;
    }

private:
    TrieNode* root;
};

int main() {
    Trie trie;
    trie.insert("apple");
    std::cout << "Search 'apple': " << trie.search("apple") << std::endl;   
    std::cout << "Search 'app': " << trie.search("app") << std::endl;       
    std::cout << "StartsWith 'app': " << trie.startsWith("app") << std::endl;
    trie.insert("app");
    std::cout << "Search 'app': " << trie.search("app") << std::endl;
    return 0;
}