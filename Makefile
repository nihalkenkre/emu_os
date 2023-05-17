CC=gcc
ASM=nasm

SRC_DIR=src
TOOLS_DIR=tools
BUILD_DIR=build

.PHONY: all floppy_image bootloader kernel tools always run clean

floppy_image: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: bootloader kernel
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img count=2880
	# mkfs.fat -F 12 -n "EMU_OS" $(BUILD_DIR)/main_floppy.img
	# dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main_floppy.img obs=1 seek=62 conv=notrunc
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/kernel.bin "::kernel.bin"
	mcopy -i $(BUILD_DIR)/main_floppy.img bochs.config "::bochs.config"
	# dd if=build/kernel.bin of=build/main_floppy.img obs=1 seek=512 conv=notrunc

bootloader: $(BUILD_DIR)/bootloader.bin

$(BUILD_DIR)/bootloader.bin: always
	$(ASM) $(SRC_DIR)/bootloader/boot.asm -f bin -o $(BUILD_DIR)/bootloader.bin

kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(ASM) $(SRC_DIR)/kernel/kernel.asm -f bin -o $(BUILD_DIR)/kernel.bin

tools: always
	mkdir -p $(BUILD_DIR)/tools
	$(CC) -g $(TOOLS_DIR)/fat/fat.c -o $(BUILD_DIR)/tools/fat

always:
	mkdir -p $(BUILD_DIR)

run: 
	qemu-system-i386 -fda $(BUILD_DIR)/main_floppy.img

clean:
	rm -fr $(BUILD_DIR)/*
