bootl_dir := src/bootl
kernel_dir := src/kernel
build_dir := build

.PHONY: all build run clean cleanup

all: build

build: $(build_dir)/final.img cleanup

$(build_dir)/final.img: $(build_dir)/temp/stageone.bin $(build_dir)/temp/stagetwo.bin
	dd if=/dev/zero of=$@ bs=512 count=19532
	parted --script $@ mklabel msdos unit s mkpart primary fat32 11s 100%
	dd if=$< of=$@ bs=446 count=1 conv=notrunc
	dd if=$(word 2, $^) of=$@ bs=512 count=10 seek=1 conv=notrunc


$(build_dir)/temp/stagetwo.bin: $(bootl_dir)/stagetwo.asm
	nasm -f bin $< -o $@

$(build_dir)/temp/stageone.bin: $(bootl_dir)/entry.asm
	mkdir -p $(build_dir)/temp
	nasm -f bin $< -o $@

cleanup: $(build_dir)/temp

run: build
	qemu-system-x86_64 -hda build/final.img


clean:
	rm -r build