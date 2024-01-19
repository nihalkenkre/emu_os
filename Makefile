CC=gcc
ASM=nasm

SRC_DIR=src
BUILD_DIR=build

IMG_DIR=assets/imgs
ROM_DIR=assets/roms

TOOLS_COPY_SRC_DIR=tools/copy/src
TOOLS_COPY_BUILD_DIR=tools/copy/build

TOOLS_COPY_PY_DIR=tools/copy

.PHONY: all floppy_image boot kernel test always run clean

all: floppy_image boot kernel test tools

floppy_image: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: boot kernel tools
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img count=28800
	dd if=$(BUILD_DIR)/boot.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
	$(BUILD_DIR)/emufs_copy.py $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/kernel.bin
	$(BUILD_DIR)/emufs_copy.py $(BUILD_DIR)/main_floppy.img $(ROM_DIR)/Chip8Logo
	$(BUILD_DIR)/emufs_copy.py $(BUILD_DIR)/main_floppy.img $(ROM_DIR)/IBMLogo
	$(BUILD_DIR)/emufs_copy.py $(BUILD_DIR)/main_floppy.img $(ROM_DIR)/Corax+
	$(BUILD_DIR)/emufs_copy.py $(BUILD_DIR)/main_floppy.img $(ROM_DIR)/Flags
	$(BUILD_DIR)/emufs_copy.py $(BUILD_DIR)/main_floppy.img $(ROM_DIR)/Quirks
	$(BUILD_DIR)/emufs_copy.py $(BUILD_DIR)/main_floppy.img $(ROM_DIR)/Keypad
	$(BUILD_DIR)/emufs_copy.py $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/a.bin
	$(BUILD_DIR)/emufs_copy.py $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/b.bin
	$(BUILD_DIR)/emufs_copy.py $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/c.bin

boot: $(BUILD_DIR)/boot.bin

$(BUILD_DIR)/boot.bin: always
	$(ASM) $(SRC_DIR)/boot/boot.asm -f bin -o $(BUILD_DIR)/boot.bin

kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(ASM) $(SRC_DIR)/kernel/kernel.asm -f bin -o $(BUILD_DIR)/kernel.bin

test: $(BUILD_DIR)/a.bin $(BUILD_DIR)/b.bin $(BUILD_DIR)/c.bin

$(BUILD_DIR)/a.bin:
	$(ASM) $(SRC_DIR)/tests/a.asm -f bin -o $(BUILD_DIR)/a.bin

$(BUILD_DIR)/b.bin:
	$(ASM) $(SRC_DIR)/tests/b.asm -f bin -o $(BUILD_DIR)/b.bin

$(BUILD_DIR)/c.bin:
	$(ASM) $(SRC_DIR)/tests/c.asm -f bin -o $(BUILD_DIR)/c.bin

tools: $(BUILD_DIR)/emufs_copy $(BUILD_DIR)/emufs_copy.py

$(BUILD_DIR)/emufs_copy: copy-always
	$(CC) $(TOOLS_COPY_SRC_DIR)/copy.c -o $(TOOLS_COPY_BUILD_DIR)/emufs_copy
	cp $(TOOLS_COPY_BUILD_DIR)/emufs_copy $(BUILD_DIR)/emufs_copy

$(BUILD_DIR)/emufs_copy.py: copy-always
	cp -p $(TOOLS_COPY_PY_DIR)/emufs_copy.py $(BUILD_DIR)/emufs_copy.py

always: copy-always
	mkdir -p $(BUILD_DIR)

copy-always:
	mkdir -p $(TOOLS_COPY_BUILD_DIR)

run: 
	qemu-system-i386 -drive format=raw,file=$(BUILD_DIR)/main_floppy.img -m 1024

debug:
	make
	bochs -f bochs.config

clean:
	rm -fr $(BUILD_DIR)/*
