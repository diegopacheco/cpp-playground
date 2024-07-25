### dependencies

Install latest g++ >= 14
https://formulae.brew.sh/formula/gcc
```
brew install gcc
```

Change ubuntu to use gcc14
```
❯ sudo update-alternatives --install /usr/bin/g++ g++ /home/linuxbrew/.linuxbrew/bin/g++-14 60
update-alternatives: using /home/linuxbrew/.linuxbrew/bin/g++-14 to provide /usr/bin/g++ (g++) in auto mode

❯ sudo update-alternatives --config g++
There is only one alternative in link group g++ (providing /usr/bin/g++): /home/linuxbrew/.linuxbrew/bin/g++-14
Nothing to configure.

❯ g++ -v
Reading specs from /home/linuxbrew/.linuxbrew/Cellar/gcc/14.1.0_2/bin/../lib/gcc/current/gcc/x86_64-pc-linux-gnu/14/specs
COLLECT_GCC=g++
COLLECT_LTO_WRAPPER=/home/linuxbrew/.linuxbrew/Cellar/gcc/14.1.0_2/bin/../libexec/gcc/x86_64-pc-linux-gnu/14/lto-wrapper
Target: x86_64-pc-linux-gnu
Configured with: ../configure --prefix=/home/linuxbrew/.linuxbrew/opt/gcc --libdir=/home/linuxbrew/.linuxbrew/opt/gcc/lib/gcc/current --disable-nls --enable-checking=release --with-gcc-major-version-only --enable-languages=c,c++,objc,obj-c++,fortran,m2 --program-suffix=-14 --with-gmp=/home/linuxbrew/.linuxbrew/opt/gmp --with-mpfr=/home/linuxbrew/.linuxbrew/opt/mpfr --with-mpc=/home/linuxbrew/.linuxbrew/opt/libmpc --with-isl=/home/linuxbrew/.linuxbrew/opt/isl --with-zstd=/home/linuxbrew/.linuxbrew/opt/zstd --with-pkgversion='Homebrew GCC 14.1.0_2' --with-bugurl=https://github.com/Homebrew/homebrew-core/issues --with-system-zlib --with-boot-ldflags='-static-libstdc++ -static-libgcc ' --disable-multilib --enable-default-pie
Thread model: posix
Supported LTO compression algorithms: zlib zstd
gcc version 14.1.0 (Homebrew GCC 14.1.0_2) 
```


### Result

```

```