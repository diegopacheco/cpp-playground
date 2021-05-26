### Install Dependencies
```bash
git clone https://github.com/fredrikwidlund/libdynamic
cd libdynamic
./autogen.sh
./configure
make install
```
### Install libreactor
```bash
git clone https://github.com/fredrikwidlund/libreactor.git
cd libreactor/
./autogen.sh
./configure
make hello
```
### Build and Run
```bash
./build.sh
./run.sh
wrk http://localhost:8080/ -R 1
```