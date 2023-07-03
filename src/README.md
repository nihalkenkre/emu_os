## Data Layout of the Disk.

- The boot loader is stored in the first 512 bytes of the disk.
- The EMU File Table is stored in the next 512 bytes.
- The table contains table entry of the format
```
    uint8_t file_name[10];
    uint32_t file_offset;
    uint32_t file_size + padding bytes to the next 512 byte boundary
```
- The raw file data is stored after the EMU File Table

*This is subject to change*

# SRC

## Folders
```
boot - the handwritten boot loader code
chip8 - the code for the chip8 emulator
draw - basic drawing functions, currently just test banner
io - File IO, reading file data, and loading them into RAM as required
kernel - kernel code
prints - print functionality
tests - tests
welcome_screen - welcome screen display
```

## Boot Process

- On startup the bios will check the last two bytes of the first sector on the disk. If the last two bytes are 0xAA55, the sector will be considered a boot sector and the disk will be considered a bootable disk. The boot sector will be loaded at memory location `0x7c00`, and execution will start from that address.
- The boot loader then loaded the EMU FS file table and loads it to memory location `0x7e00`.
- It will then look for the `kernel` table entry within the table.
- Once found it will load the `kernel` at `0x8000`, and makes a far jump to that location essentially handing over execution to the kernel.