# EMU OS

An operating system written from scratch to eventually run the Chip8 apps and later on the NES apps.


## Data Layout of the Disk.

- The bootloader is stored in the first 512 bytes of the disk.
- The kernel is stored in the 1024 bytes after the bootloader.
- The next 2048 bytes contain the file info. 10 byte file name and data of the file.
- The raw file data comes next, tightly packed. A 320x200 banner data will be stored before the actual file data.

*This is subject to change*

## Functionality
- The bootloader will load the kernel.
- The kernel will display the banner of the first file, and subsequently update the banner when the right / left arrow is pressed.
- Pressing Enter will load the app into memory and execute it.
- Pressing Esc when inside the app will bring the user back to step 2.

*This is subject to change*