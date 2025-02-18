[[nodiscard]] int sum(int a, int b) { 
    return a + b; 
}

int main() {
    sum(10, 20); // This will generate a compiler warning
    return 0;
}