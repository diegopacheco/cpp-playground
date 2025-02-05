### RCU Locking concept

RCU (Read-Copy-Update) is a synchronization mechanism that allows multiple readers to access data concurrently with writers. Writers create a new copy of the data, update it, and then switch pointers atomically. This minimizes locking overhead for readers.

### Alternatives

Other models and alternatives include:

* Mutexes: Traditional locking mechanism.
* Read-Write Locks: Allows multiple readers or one writer.
* Lock-Free Programming: Uses atomic operations to avoid locks.

https://blog.envoyproxy.io/envoy-threading-model-a8d44b922310