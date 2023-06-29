CC=gcc
ASM=nasm

SRC_DIR=src
BUILD_DIR=build

IMG_DIR=assets/imgs
ROM_DIR=assets/roms

.PHONY: all vbe floppy_image boot kernel test always run clean

all: floppy_image boot kernel test

floppy_image: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: boot kernel test
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img count=28800
	dd if=$(BUILD_DIR)/boot.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
	../emufs_tools/build/emufs_copy $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/kernel.bin
	../emufs_tools/build/emufs_copy $(BUILD_DIR)/main_floppy.img $(ROM_DIR)/Chip8Logo
	../emufs_tools/build/emufs_copy $(BUILD_DIR)/main_floppy.img $(ROM_DIR)/IBMLogo
	../emufs_tools/build/emufs_copy $(BUILD_DIR)/main_floppy.img $(ROM_DIR)/Corax+
	../emufs_tools/build/emufs_copy $(BUILD_DIR)/main_floppy.img $(ROM_DIR)/Flags
	../emufs_tools/build/emufs_copy $(BUILD_DIR)/main_floppy.img $(ROM_DIR)/Quirks
	../emufs_tools/build/emufs_copy $(BUILD_DIR)/main_floppy.img $(ROM_DIR)/Keypad

boot: $(BUILD_DIR)/boot.bin

$(BUILD_DIR)/boot.bin: always
	$(ASM) $(SRC_DIR)/boot/boot.asm -w+* -f bin -o $(BUILD_DIR)/boot.bin

kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(ASM) $(SRC_DIR)/kernel/kernel.asm -w+* -f bin -o $(BUILD_DIR)/kernel.bin

test: $(BUILD_DIR)/a.bin $(BUILD_DIR)/b.bin $(BUILD_DIR)/c.bin

$(BUILD_DIR)/a.bin:
	$(ASM) $(SRC_DIR)/tests/a.asm -w+* -f bin -o $(BUILD_DIR)/a.bin

$(BUILD_DIR)/b.bin:
	$(ASM) $(SRC_DIR)/tests/b.asm -w+* -f bin -o $(BUILD_DIR)/b.bin

$(BUILD_DIR)/c.bin:
	$(ASM) $(SRC_DIR)/tests/c.asm -w+* -f bin -o $(BUILD_DIR)/c.bin

always:
	mkdir -p $(BUILD_DIR)

run: 
	qemu-system-i386 -drive format=raw,file=$(BUILD_DIR)/main_floppy.img -m 1024

debug:
	bochs -f bochs.config

clean:
	rm -fr $(BUILD_DIR)/*
