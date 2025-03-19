需要注意在64位上面编译32位程序需要用到以下命令：

```makefile
gcc -m32 -I lib/kernel/ -I lib/ -I kernel/ -c -fno-builtin -o xxx -fno-stack-protector
nasm -f elf32 -o xxx
```
