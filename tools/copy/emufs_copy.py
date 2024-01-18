#!/usr/bin/python3

import argparse
import os

BOOT_SECTOR_SIZE = 512
EMUFS_TABLE_SIZE = 512
EMUFS_TABLE_ENTRY_SIZE = 18
PADDING_BOUNDARY = 512

class EMUfsTableEntry:
    def __init__(self, table_entry_bytes: bytes=None) -> None:
        if table_entry_bytes is None:
            return
        
        self.file_name = table_entry_bytes[0:10].decode('utf-8')
        self.file_offset = int.from_bytes(table_entry_bytes[10:14], 'little')
        self.file_size = int.from_bytes(table_entry_bytes[14:18], 'little')

    def __bytes__(self) -> bytearray:
        return_bytes = bytearray(self.file_name, 'utf-8')
        return_bytes.append(bytearray(int.to_bytes(self.file_offset, 4, 'little')))
        return_bytes.append(bytearray(int.to_bytes(self.file_size, 4,'little')))

        return bytes(return_bytes)

    def __len__() -> int:
        return 18

    def __str__(self) -> str:
        return f'\n\
                Filename: {self.file_name}\n\
                File offset: {self.file_offset}\n\
                File size: {self.file_size}\n'

def main(args):
    emufs_table_entry_count = int(EMUFS_TABLE_SIZE / EMUFS_TABLE_ENTRY_SIZE)
    emufs_table = []

    with open(args.image, 'rb+') as img:
        with open(args.file, 'rb') as file:
            # Read the emufs table from the file
            img.seek(BOOT_SECTOR_SIZE)
            emufs_table_bytes = img.read(EMUFS_TABLE_SIZE)
            
            # Parse the data into list of table entries
            for emufs_table_entry_idx in range(emufs_table_entry_count):
                offset_into_bytes = emufs_table_entry_idx * EMUFS_TABLE_ENTRY_SIZE
                emufs_table_entry = EMUfsTableEntry(emufs_table_bytes[offset_into_bytes:offset_into_bytes + EMUFS_TABLE_ENTRY_SIZE])

                if emufs_table_entry.file_size > 0:
                    emufs_table.append(emufs_table_entry)

            # Calculate the offset from the start of the img where the new data will be copied to
            file_offset = BOOT_SECTOR_SIZE + EMUFS_TABLE_SIZE

            for emufs_table_entry in emufs_table:
                if emufs_table_entry.file_size == 0:
                    break

                file_offset += emufs_table_entry.file_size

            # Get the size of the file to copy
            file_size = os.path.getsize(args.file)

            # Get the number of padding bytes to the nearsest 512 byte boundary
            diff_byte_count = file_size % PADDING_BOUNDARY
            if diff_byte_count > 0:
                diff_byte_count = PADDING_BOUNDARY - diff_byte_count

            # Create a new table entry to be written to the img
            emufs_table_entry = EMUfsTableEntry()
            emufs_table_entry.file_offset = file_offset
            emufs_table_entry.file_size = file_size + diff_byte_count

            # Extract the file name from the full path
            file_name = os.path.basename(args.file)
            emufs_table_entry.file_name = file_name[0:10]

            # Add the new entry to the emufs table
            emufs_table.append(emufs_table_entry)
            
            # Write the updated emufs table to the img file
            img.seek(BOOT_SECTOR_SIZE)
            # img.write(bytes(emufs_table))
            print(bytes(emufs_table_entry))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument('image', help='Disk image to copy the file to')
    parser.add_argument('file', help='File to copy')

    main (parser.parse_args())