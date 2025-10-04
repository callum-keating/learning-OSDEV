bootl_dir := src/bootl
kernel_dir := src/kernel
build_dir := build
SHELL := /bin/bash

.PHONY: all build run clean cleanup

all: build

build: $(build_dir)/final.img cleanup

$(build_dir)/final.img: $(build_dir)/temp/stageone.bin $(build_dir)/temp/stagetwo.bin $(build_dir)/temp/kernel.bin
	dd if=/dev/zero of=$@ bs=512 count=19532
	parted --script build/final.img mklabel msdos
	parted --script build/final.img mkpart primary fat32 2048s 100%
	sudo losetup -o 1048576 /dev/loop0 build/final.img
	sudo mkfs.fat -F32 /dev/loop0
	sudo losetup -d /dev/loop0
	dd if=$< of=$@ bs=446 count=1 conv=notrunc
	dd if=$(word 2, $^) of=$@ bs=512 count=10 seek=1 conv=notrunc
	MTOOLSRC=<(echo 'drive z: file="build/final.img" partition=1') mcopy $(word 3, $^) z:/


$(build_dir)/temp/stagetwo.bin: $(bootl_dir)/stagetwo.asm
	nasm -f bin $< -o $@

$(build_dir)/temp/stageone.bin: $(bootl_dir)/entry.asm
	mkdir -p $(build_dir)/temp
	nasm -f bin $< -o $@

$(build_dir)/temp/kernel.o: $(kernel_dir)/kernel.c
	gcc -ffreestanding -m64 -c $< -o $@

$(build_dir)/temp/kernel.bin: $(build_dir)/temp/kernel.o
	ld -o $@ -T $(kernel_dir)/linker.ld $< --oformat=binary

cleanup: $(build_dir)/temp
	rm -r $<

run: build
	qemu-system-x86_64 -hda build/final.img


clean:
	rm -r build