# EMU OS

An operating system written from scratch to eventually run the Chip8 apps and later on the NES apps.


## Data Layout of the Disk.

- The bootloader is stored in the first 512 bytes of the disk.
- The EMU File Table is stored in the next 4096 bytes.
- The table contains table entry of the format
```
    uint8_t file_name[10];
    uint16_t file_offset;
    uint16_t file_size + padding bytes to the next 512 byte boundary
```
- The raw file data is stored after the EMU File Table

*This is subject to change*

## Functionality
- The bootloader will load the kernel.
- The kernel will display the banner of the first file, and subsequently update the banner when the right / left arrow is pressed.
- Pressing Enter will load the app into memory and execute it.
- Pressing Esc when inside the app will bring the user back to step 2.

*This is subject to change*