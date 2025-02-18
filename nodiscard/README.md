### Build

```bash
./build.sh
```

### Run

```bash
./run.sh
```

### Result

```
❯ ./run.sh
src/main.cpp: In function 'int main()':
src/main.cpp:6:8: warning: ignoring return value of 'int sum(int, int)', declared with attribute 'nodiscard' [-Wunused-result]
    6 |     sum(10, 20); // This will generate a compiler warning
      |     ~~~^~~~~~~~
src/main.cpp:1:19: note: declared here
    1 | [[nodiscard]] int sum(int a, int b) {
      |    
``` 
