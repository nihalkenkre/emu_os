CC=gcc
ASM=nasm

SRC_DIR=src
BUILD_DIR=build

IMG_DIR=assets/imgs
ROM_DIR=assets/roms

TOOLS_COPY_SRC_DIR=tools/copy/src
TOOLS_COPY_BUILD_DIR=tools/copy/build

.PHONY: all floppy_image boot kernel test always run clean

all: floppy_image boot kernel test tools

floppy_image: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: boot kernel tools
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img count=28800
	dd if=$(BUILD_DIR)/boot.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
	$(TOOLS_COPY_BUILD_DIR)/emufs_copy $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/kernel.bin
	$(TOOLS_COPY_BUILD_DIR)/emufs_copy $(BUILD_DIR)/main_floppy.img $(ROM_DIR)/Chip8Logo
	$(TOOLS_COPY_BUILD_DIR)/emufs_copy $(BUILD_DIR)/main_floppy.img $(ROM_DIR)/IBMLogo
	$(TOOLS_COPY_BUILD_DIR)/emufs_copy $(BUILD_DIR)/main_floppy.img $(ROM_DIR)/Corax+
	$(TOOLS_COPY_BUILD_DIR)/emufs_copy $(BUILD_DIR)/main_floppy.img $(ROM_DIR)/Flags
	$(TOOLS_COPY_BUILD_DIR)/emufs_copy $(BUILD_DIR)/main_floppy.img $(ROM_DIR)/Quirks
	$(TOOLS_COPY_BUILD_DIR)/emufs_copy $(BUILD_DIR)/main_floppy.img $(ROM_DIR)/Keypad

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

tools: $(BUILD_DIR)/emufs_copy

$(BUILD_DIR)/emufs_copy: copy-always
	$(CC) $(TOOLS_COPY_SRC_DIR)/copy.c -o $(TOOLS_COPY_BUILD_DIR)/emufs_copy
	cp $(TOOLS_COPY_BUILD_DIR)/emufs_copy $(BUILD_DIR)/emufs_copy

always: copy-always
	mkdir -p $(BUILD_DIR)

copy-always:
	mkdir -p $(TOOLS_COPY_BUILD_DIR)

run: 
	qemu-system-i386 -drive format=raw,file=$(BUILD_DIR)/main_floppy.img -m 1024

debug:
	bochs -f bochs.config

clean:
	rm -fr $(BUILD_DIR)/*
