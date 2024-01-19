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
        
        self.file_name = table_entry_bytes[0:10]
        self.file_offset = table_entry_bytes[10:14]
        self.file_size = table_entry_bytes[14:18]

    def __bytes__(self) -> bytearray:
        return_bytes = bytearray()

        return_bytes.extend(self.file_name)
        return_bytes.extend(self.file_offset)
        return_bytes.extend(self.file_size)

        return bytes(return_bytes)

    def __len__() -> int:
        return 18

    def __str__(self) -> str:
        return f'\n\
                Filename: {self.file_name.decode("utf-8")}\n\
                File offset: {int.from_bytes(self.file_offset, 4, "little")}\n\
                File size: {int.from_bytes(self.file_size, 4, "little")}\n'

def main(args):
    emufs_table_entry_max_count = int(EMUFS_TABLE_SIZE / EMUFS_TABLE_ENTRY_SIZE)
    emufs_table = []

    with open(args.image, 'rb+') as img:
        with open(args.file, 'rb') as file:

            # Read the emufs table from the file
            img.seek(BOOT_SECTOR_SIZE)
            emufs_table_bytes = img.read(EMUFS_TABLE_SIZE)
            
            # Parse the data into list of table entries
            for emufs_table_entry_idx in range(emufs_table_entry_max_count):
                offset_into_bytes = emufs_table_entry_idx * EMUFS_TABLE_ENTRY_SIZE
                emufs_table_entry = EMUfsTableEntry(emufs_table_bytes[offset_into_bytes:offset_into_bytes + EMUFS_TABLE_ENTRY_SIZE])

                if int.from_bytes(emufs_table_entry.file_size, 'little') > 0:
                    emufs_table.append(emufs_table_entry)

            # Calculate the offset from the start of the img where the new data will be copied to
            file_offset = BOOT_SECTOR_SIZE + EMUFS_TABLE_SIZE

            for emufs_table_entry in emufs_table:
                if emufs_table_entry.file_size == 0:
                    break

                file_offset += int.from_bytes(emufs_table_entry.file_size, 'little')

            # Get the size of the file to copy
            file_size = os.path.getsize(args.file)

            # Get the number of padding bytes to the nearest 512 byte boundary
            diff_byte_count = file_size % PADDING_BOUNDARY
            if diff_byte_count > 0:
                diff_byte_count = PADDING_BOUNDARY - diff_byte_count

            # Extract the file name from the full path
            file_name = os.path.basename(args.file)

            # Create a new table entry to be written to the img
            table_entry_bytes = bytearray()
            table_entry_bytes.extend(file_name[0:10].encode('utf-8'))

            # Add padding bytes upto 10 bytes for file name
            for _ in range(10 - len(table_entry_bytes)):
                table_entry_bytes.append(0)

            table_entry_bytes.extend(int.to_bytes(file_offset, 4, 'little'))
            table_entry_bytes.extend(int.to_bytes(file_size + diff_byte_count, 4,'little'))

            # Add a new entry with the above bytes to the emufs table
            emufs_table.append(EMUfsTableEntry(table_entry_bytes))
            
            # Set the file pointer to the end of the boot sector
            img.seek(BOOT_SECTOR_SIZE)

            # Write the entries of the table to the file
            for emufs_table_entry in emufs_table:
                img.write(bytes(emufs_table_entry))

            # Read the data from the file to be copied
            file_data = file.read(file_size)

            # Set the img file pointer to the file offset value
            img.seek(file_offset)

            # Write the data to the img
            img.write(file_data)

            # Write the padding bytes
            zeros = [0] * diff_byte_count
            img.write(bytes(zeros))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument('image', help='Disk image to copy the file to')
    parser.add_argument('file', help='File to copy')

    main (parser.parse_args())