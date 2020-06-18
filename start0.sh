#!/bin/bash
nasm -f elf64 -O 0 -w-all -o start.o start.asm
ld -o start start.o
rm start.o
./start
