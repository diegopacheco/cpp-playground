### Rationale

std::atomic can only be used with types that are trivially copyable. Trivially copyable `memcpy` types are those that can be copied with memcpy and have no user-defined copy constructors, copy assignment operators, or destructors. Here are some examples of types you can and cannot use with std::atomic:

Types you can use with std::atomic:
* Primitive types: int, float, double, char, etc.
* Pointers: int*, void*, etc.

Types you cannot use with std::atomic:
Non-trivially copyable types: std::string, std::vector, std::unique_ptr, etc.
User-defined types with non-trivial copy constructors, copy assignment operators, or destructors.

### Result

```bash
./run.sh
```

```
❯ ./run.sh
C++ Standard: 202002:
int is lock-free
double is lock-free
char is lock-free
int* is lock-free
std::shared_ptr<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > > is NOT lock-free
```