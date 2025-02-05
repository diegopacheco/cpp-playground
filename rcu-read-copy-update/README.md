### RCU Locking concept

RCU (Read-Copy-Update) is a synchronization mechanism that allows multiple readers to access data concurrently with writers. Writers create a new copy of the data, update it, and then switch pointers atomically. This minimizes locking overhead for readers.

In computer science, read-copy-update (RCU) is a synchronization mechanism that avoids the use of lock primitives while multiple threads concurrently read and update elements that are linked through pointers and that belong to shared data structures (e.g., linked lists, trees, hash tables).[1]

RCU is efficient if you dont have many updates, otherwise there is a memory overhead. 

### Alternatives

Other models and alternatives include:

* Mutexes: Traditional locking mechanism.
* Read-Write Locks: Allows multiple readers or one writer.
* Lock-Free Programming: Uses atomic operations to avoid locks.

### Links

* https://blog.envoyproxy.io/envoy-threading-model-a8d44b922310
* https://en.wikipedia.org/wiki/Read-copy-update
* https://www.youtube.com/watch?v=rxQ5K9lo034&ab_channel=CppCon
* https://en.wikipedia.org/wiki/Copy-on-write#:~:text=Copy%2Don%2Dwrite%20(COW,one%20tries%20to%20modify%20it.