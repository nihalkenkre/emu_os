CC=gcc
ASM=nasm

SRC_DIR=src
BUILD_DIR=build

.PHONY: all floppy_image bootloader kernel always run clean

floppy_image: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: bootloader kernel
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img count=2880
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
	# ../emufs_tools/build/emufs_copy $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/kernel.bin
	dd if=$(BUILD_DIR)/kernel.bin of=$(BUILD_DIR)/main_floppy.img obs=1 seek=512 conv=notrunc

bootloader: $(BUILD_DIR)/bootloader.bin

$(BUILD_DIR)/bootloader.bin: always
	$(ASM) $(SRC_DIR)/bootloader/boot.asm -w+* -f bin -o $(BUILD_DIR)/bootloader.bin

kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(ASM) $(SRC_DIR)/kernel/kernel.asm -w+* -f bin -o $(BUILD_DIR)/kernel.bin

always:
	mkdir -p $(BUILD_DIR)

run: 
	qemu-system-i386 -fda $(BUILD_DIR)/main_floppy.img

clean:
	rm -fr $(BUILD_DIR)/*
