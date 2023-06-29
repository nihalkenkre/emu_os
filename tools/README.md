# Tools

Custom tools for dealing with the EMU OS filesystem, since it is a non standard file system.

## Current disk layout

- The bootloader is stored in the first 512 bytes of the disk.
- The EMU File Table is stored in the next 512 bytes.
- The table contains tightly packed table entries of the format
```
    uint8_t file_name[10];
    uint32_t file_offset;
    uint32_t file_size + padding bytes to the next 512 byte boundary
```
- The raw file data is stored after the EMU File Table

## Copy

```
emufs_copy <disk_image> <file_to_copy>
```
It takes a file and copies the raw data to the image. It adds an entry to the file table.