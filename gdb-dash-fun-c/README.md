### Install
```bash
wget -P ~ https://git.io/.gdbinit 
pip install pygments
```
### Use it
```bash
./gcc-compile.sh 
gdb target/main
```
```bash
b 10
list
source ./.gdbinit
dashboard -enabled
dashboard -layout registers assembly source variables stack 
run
```
