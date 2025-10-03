bootl_dir := src/bootl
build_dir := build

.PHONY: all build run clean

all: build

# Final disk image is the goal of the build
build: $(build_dir)/disk.img

# Assemble the bootloader
$(build_dir)/bootl.bin: $(bootl_dir)/entry.asm
	mkdir -p $(build_dir)
	mkdir -p $(build_dir)/fatmnt
	nasm -f bin $(bootl_dir)/entry.asm -o $(build_dir)/bootl.bin

# Create the disk image and write the bootloader into it
$(build_dir)/disk.img: $(build_dir)/bootl.bin
	dd if=/dev/zero of=$(build_dir)/disk.img bs=4096 count=1
	dd if=/dev/zero of=$(build_dir)/fat.img bs=4096 count=65531
	mkfs.fat $(build_dir)/fat.img
	dd if=$(build_dir)/bootl.bin of=$(build_dir)/disk.img conv=notrunc
	sudo mount -o loop $(build_dir)/fat.img $(build_dir)/fatmnt
	cat $(build_dir)/disk.img $(build_dir)/fat.img > $(build_dir)/final.img
#build a kernel and copy it over, combine the images and have the bootloader then launch the kernel

# Run in QEMU
run: build
	qemu-system-x86_64 -hda $(build_dir)/final.img

# Clean everything
clean:
	sudo umount -R $(build_dir)/fatmnt
	rm -rf $(build_dir)
