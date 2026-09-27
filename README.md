# cpp-playground

Hands-on POCs of C and C++. Every project is small, self-contained and ships with its own build/run scripts.

## 🧱 Language Basics

The building blocks: control flow, loops, functions, strings and input.
Everything else in this repo is built on top of these.

* [basic-conditionals](basic-conditionals/) - if, else and switch
* [basic-foreach](basic-foreach/) - Range-based for loops
* [for-each-fun](for-each-fun/) - std::for_each over containers
* [loops-fun](loops-fun/) - for, while and do-while loops
* [goto](goto/) - goto, and why you should avoid it
* [default-func-args-fun](default-func-args-fun/) - Functions with default arguments
* [inline-functions-fun](inline-functions-fun/) - Inline functions
* [basic-namescapes-fun](basic-namescapes-fun/) - Namespaces
* [headers-fun](headers-fun/) - Splitting code into .h and .cpp files
* [ifdef](ifdef/) - Preprocessor conditionals with #ifdef
* [auto](auto/) - Type deduction with auto
* [strings-fun](strings-fun/) - std::string operations
* [strucs-fun](strucs-fun/) - Structs
* [arrays-fun](arrays-fun/) - C-style arrays
* [conversions-fun](conversions-fun/) - String to number conversions with stoul and friends
* [user-input-simple](user-input-simple/) - Reading user input from std::cin
* [basic-exceptions-fun](basic-exceptions-fun/) - try, catch and throw
* [nodiscard](nodiscard/) - [[nodiscard]] attribute warnings

## 🎯 Pointers & Memory

C++ gives you direct control over memory.
Pointers, references and smart pointers decide who owns what and when it is freed.

* [print-pointer](print-pointer/) - Pointer arithmetic over an array
* [binary-pointers-array-hello-world](binary-pointers-array-hello-world/) - Hello world printed from binary through pointers
* [null-pointers-fun](null-pointers-fun/) - nullptr and null checks
* [reference-fun](reference-fun/) - References vs pointers
* [delete-free-memory-fun](delete-free-memory-fun/) - new, delete, malloc and free
* [smart-pointers-fun](smart-pointers-fun/) - unique_ptr, shared_ptr and weak_ptr
* [memcpy](memcpy/) - Copying raw bytes with memcpy
* [swap](swap/) - std::swap
* [dynamic-buffer-adj](dynamic-buffer-adj/) - Buffer that grows and shrinks its capacity with the load

## 🏛️ Object-Oriented Programming

Classes bundle data with behavior.
Inheritance and virtual functions let one interface have many implementations.

* [basic-oop-fun](basic-oop-fun/) - Classes, constructors and members
* [basic-oop-inheritance-fun](basic-oop-inheritance-fun/) - Inheritance
* [basic-oop-polymorphism-fun](basic-oop-polymorphism-fun/) - Polymorphism
* [virtual-functions-fun](virtual-functions-fun/) - Virtual functions and dynamic dispatch
* [friendly-visibility-fun](friendly-visibility-fun/) - friend classes reaching private members
* [explicit](explicit/) - explicit constructors blocking implicit conversions
* [operator-plus-overloading-fun](operator-plus-overloading-fun/) - Overloading operator+
* [type-erasure-fun](type-erasure-fun/) - Type erasure: one interface over unrelated types

## 🧬 Templates & Generics

Templates generate code at compile time for any type.
Type traits and variadic templates make that code smarter.

* [templates-fun](templates-fun/) - Function and class templates
* [templates-generics-cpp-fun](templates-generics-cpp-fun/) - Generic containers with templates
* [cpp-template-generics](cpp-template-generics/) - Generic functions with templates
* [cpp-variadic-templates](cpp-variadic-templates/) - Variadic templates
* [cpp-type-traits](cpp-type-traits/) - std::is_integral and other type traits
* [cpp-constexpr](cpp-constexpr/) - Compile-time computation with constexpr

## 🆕 Modern C++ (17 / 20 / 23)

Each new standard adds features that make C++ safer and shorter to write.

* [cpp-17-folding-expressions](cpp-17-folding-expressions/) - C++17 fold expressions
* [cpp-17-structured-bindings](cpp-17-structured-bindings/) - C++17 structured bindings
* [cpp-optional](cpp-optional/) - std::optional
* [optional-fun](optional-fun/) - std::optional for values that may be missing
* [cpp-variant](cpp-variant/) - std::variant type-safe unions
* [cpp-tuple](cpp-tuple/) - std::tuple
* [cpp-fs-iterator](cpp-fs-iterator/) - std::filesystem directory iterator
* [cpp-20-concepts-simple](cpp-20-concepts-simple/) - C++20 concepts
* [cpp-20-constint](cpp-20-constint/) - C++20 constinit
* [cpp-20-coroutines-simple](cpp-20-coroutines-simple/) - C++20 coroutines
* [cpp-20-immediate-functions](cpp-20-immediate-functions/) - C++20 consteval immediate functions
* [cpp-20-likely-unlikely-attributes](cpp-20-likely-unlikely-attributes/) - C++20 [[likely]] and [[unlikely]]
* [cpp-20-modules-simple](cpp-20-modules-simple/) - C++20 modules with g++ 14
* [cpp-20-ranges-simple](cpp-20-ranges-simple/) - C++20 ranges and views
* [cpp-20-usingenus](cpp-20-usingenus/) - C++20 using enum
* [cpp-20-variadic-function-templates-simple](cpp-20-variadic-function-templates-simple/) - C++20 abbreviated variadic function templates
* [cpp-23](cpp-23/) - C++23 build setup

## 📦 STL

The Standard Template Library ships ready-made containers and algorithms.

* [cpp-vector](cpp-vector/) - std::vector
* [vector-reverse](vector-reverse/) - Reversing a std::vector
* [cpp-map](cpp-map/) - std::map
* [stl-list-fun](stl-list-fun/) - std::list
* [stl-queue-fun](stl-queue-fun/) - std::queue
* [stl-functor-fun](stl-functor-fun/) - Functors with std::transform
* [bitset-fun](bitset-fun/) - std::bitset
* [cpp-random](cpp-random/) - Random numbers with <random>
* [random-fun](random-fun/) - Random number generation

## 🧵 Concurrency

Threads run work in parallel.
Mutexes, atomics and condition variables keep them from stepping on each other.

* [threads](threads/) - std::thread
* [threads-fun](threads-fun/) - Spawning and joining threads
* [future](future/) - std::async and std::future
* [mutex](mutex/) - std::mutex
* [cpp-mutex](cpp-mutex/) - Guarding shared state with std::mutex
* [lock_guard](lock_guard/) - RAII locking with std::lock_guard
* [unique_lock](unique_lock/) - Flexible locking with std::unique_lock
* [condition-variable](condition-variable/) - std::condition_variable wait and notify
* [atomics](atomics/) - std::atomic counter across threads
* [atomic-lock-check](atomic-lock-check/) - Which types std::atomic can hold lock-free
* [rcu-read-copy-update](rcu-read-copy-update/) - RCU: readers never block while writers swap copies

## 🌳 Data Structures & Algorithms

Classic structures implemented from scratch.

* [stack](stack/) - Stack
* [simple-queue](simple-queue/) - Queue
* [double-linked-list](double-linked-list/) - Doubly linked list
* [binary_tree](binary_tree/) - Binary tree
* [bplus-tree](bplus-tree/) - B+ tree
* [skip-list](skip-list/) - Skip list
* [trie](trie/) - Trie
* [min-heap](min-heap/) - Min heap
* [max-heap](max-heap/) - Max heap
* [graph](graph/) - Graph with adjacency lists
* [bit-array](bit-array/) - Bit array
* [pattern-searching-fun](pattern-searching-fun/) - Finding every occurrence of a pattern in a string

## 🚦 Rate Limiting

Algorithms that decide how many requests pass per unit of time.

* [token-bucket](token-bucket/) - Token bucket rate limiter
* [leaky-bucket](leaky-bucket/) - Leaky bucket rate limiter
* [users-per-day](users-per-day/) - Turning requests per second into users per day

## 🔢 Bytes & Encoding

Moving between text, hex and network byte order.

* [hex](hex/) - String to hex
* [from-hex](from-hex/) - Hex to string
* [cpp-ntohl](cpp-ntohl/) - Network to host byte order with ntohl

## 🌐 Networking & Servers

Sockets, event loops and web frameworks.

* [epoll](epoll/) - Linux epoll event loop
* [tcp-game](tcp-game/) - Client/server guessing game over TCP sockets
* [fun-drogon](fun-drogon/) - Drogon web framework
* [facil-appname](facil-appname/) - facil.io HTTP and chat servers in C
* [facil-mini](facil-mini/) - Minimal facil.io setup with UUID generation
* [libreactor-2-fun](libreactor-2-fun/) - libreactor HTTP server in C

## 🔌 Libraries & Integrations

Talking to databases, parsing JSON and big numbers with third-party libraries.

* [redis-cpp](redis-cpp/) - Redis client with redis-cpp
* [sqlite3-fun](sqlite3-fun/) - SQLite3 from C++
* [jsoncpp](jsoncpp/) - JSON parsing with jsoncpp
* [boost-bigint-fun](boost-bigint-fun/) - Big integers with Boost.Multiprecision
* [chadstr-fun](chadstr-fun/) - chadstr string library in C
* [file-fun](file-fun/) - Reading and writing a file
* [files-fun](files-fun/) - File I/O with fstream

## 🛠️ Tooling & Testing

Debugging and testing C++ code.

* [GoogleTest-fun](GoogleTest-fun/) - Unit tests with GoogleTest
* [gdb-dash-fun-c](gdb-dash-fun-c/) - Debugging C with GDB Dashboard

## 🎮 Games & Graphics

Small games in the terminal and on screen.

* [snake-cpp](snake-cpp/) - Snake
* [tetris-cpp](tetris-cpp/) - Tetris
* [pong-game](pong-game/) - Pong
* [handman-game-cpp](handman-game-cpp/) - Hangman
* [sfml-hello](sfml-hello/) - Hello world window with SFML
* [cpp-amazon-metal](cpp-amazon-metal/) - Amazon rainforest scene rendered with Apple Metal
