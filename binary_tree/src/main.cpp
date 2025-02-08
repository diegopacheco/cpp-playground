#include <iostream>

struct TreeNode {
    int value;
    TreeNode* left;
    TreeNode* right;

    TreeNode(int val) : value(val), left(nullptr), right(nullptr) {}
};

class BinaryTree {
public:
    BinaryTree() : root(nullptr) {}

    void insert(int value) {
        root = insertRec(root, value);
    }

    void inorder() const {
        inorderRec(root);
        std::cout << '\n';
    }

    void preorder() const {
        preorderRec(root);
        std::cout << '\n';
    }

    void postorder() const {
        postorderRec(root);
        std::cout << '\n';
    }

private:
    TreeNode* root;

    TreeNode* insertRec(TreeNode* node, int value) {
        if (node == nullptr) {
            return new TreeNode(value);
        }

        if (value < node->value) {
            node->left = insertRec(node->left, value);
        } else if (value > node->value) {
            node->right = insertRec(node->right, value);
        }

        return node;
    }

    void inorderRec(TreeNode* node) const {
        if (node != nullptr) {
            inorderRec(node->left);
            std::cout << node->value << ' ';
            inorderRec(node->right);
        }
    }

    void preorderRec(TreeNode* node) const {
        if (node != nullptr) {
            std::cout << node->value << ' ';
            preorderRec(node->left);
            preorderRec(node->right);
        }
    }

    void postorderRec(TreeNode* node) const {
        if (node != nullptr) {
            postorderRec(node->left);
            postorderRec(node->right);
            std::cout << node->value << ' ';
        }
    }
};

int main() {
    BinaryTree tree;
    tree.insert(5);
    tree.insert(3);
    tree.insert(7);
    tree.insert(2);
    tree.insert(4);
    tree.insert(6);
    tree.insert(8);

    std::cout << "Inorder traversal: ";
    tree.inorder();

    std::cout << "Preorder traversal: ";
    tree.preorder();

    std::cout << "Postorder traversal: ";
    tree.postorder();

    return 0;
}