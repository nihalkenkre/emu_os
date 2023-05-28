CC=gcc
ASM=nasm

SRC_DIR=src
BUILD_DIR=build

IMG_DIR=assets/imgs

.PHONY: all floppy_image boot kernel always run clean

floppy_image: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: boot kernel
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img count=2880
	dd if=$(BUILD_DIR)/boot.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
	../emufs_tools/build/emufs_copy $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/kernel.bin
	../emufs_tools/build/emufs_copy $(BUILD_DIR)/main_floppy.img $(IMG_DIR)/rocket.bmp

boot: $(BUILD_DIR)/boot.bin

$(BUILD_DIR)/boot.bin: always
	$(ASM) $(SRC_DIR)/boot/boot.asm -w+* -f bin -o $(BUILD_DIR)/boot.bin

kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(ASM) $(SRC_DIR)/kernel/kernel.asm -w+* -f bin -o $(BUILD_DIR)/kernel.bin

always:
	mkdir -p $(BUILD_DIR)

run: 
	qemu-system-i386 -drive format=raw,file=$(BUILD_DIR)/main_floppy.img

clean:
	rm -fr $(BUILD_DIR)/*
