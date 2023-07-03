#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>

typedef struct emufs_table_entry
{
    uint8_t file_name[10];
    uint32_t file_offset;
    uint32_t file_size;
} __attribute__((packed)) emufs_table_entry;

uint16_t BOOT_SECTOR_SIZE = 512;
uint16_t EMUFS_TABLE_SIZE = 512;
uint16_t PADDING_BOUNDARY = 512;

emufs_table_entry *g_table = NULL;

int main(int argc, char **argv)
{
    int8_t ret_val = 0;
    uint32_t emufs_table_entry_size = (uint32_t)sizeof(emufs_table_entry);

    if (argc < 3)
    {
        printf("Usage: copy <disk_image> <file_path>.\n");
        ret_val = -1;

        goto shutdown;
    }

    // Open the image disk for reading / writing.
    FILE *img = fopen(argv[1], "rb+");
    if (!img)
    {
        printf("Could not image %s for reading/writing.\n", argv[1]);
        ret_val = -1;
        goto shutdown;
    }

    // Open the file whose data has to be copied to the img
    FILE *file_to_copy = fopen(argv[2], "rb");
    if (!file_to_copy)
    {
        printf("Could not open file %s for copying.\n", argv[2]);
        ret_val = -2;
        goto shutdown;
    }

    // Get table entry count and allocate memory
    uint32_t emufs_table_entry_count = EMUFS_TABLE_SIZE / emufs_table_entry_size;

    g_table = (emufs_table_entry *)calloc(emufs_table_entry_count, emufs_table_entry_size);

    // Get all the table entries
    fseek(img, BOOT_SECTOR_SIZE, SEEK_SET);
    fread(g_table, emufs_table_entry_size, emufs_table_entry_count, img);

    // Calculate the offset from the start of the img where the file data will be copied to
    uint32_t file_offset = BOOT_SECTOR_SIZE + EMUFS_TABLE_SIZE;
    uint32_t entry_idx = 0;
    for (entry_idx = 0; entry_idx < emufs_table_entry_count; ++entry_idx)
    {
        if (g_table[entry_idx].file_size == 0)
        {
            break;
        }

        file_offset += g_table[entry_idx].file_size;
    }

    // Get the size of the file to copy
    fseek(file_to_copy, 0, SEEK_END);
    uint32_t file_size = ftell(file_to_copy);
    rewind(file_to_copy);

    // Get the padding bytes upto the next 512 byte sector
    uint32_t diff_byte_count = (file_size % PADDING_BOUNDARY);
    if (diff_byte_count > 0)
    {
        diff_byte_count = PADDING_BOUNDARY - diff_byte_count;
    }

    // Update the table in the img file
    emufs_table_entry new_entry = {
        .file_offset = file_offset,
        .file_size = file_size + diff_byte_count,
    };

    // extract the file name from the full path
    char *filename = NULL;
    char *tokens = strtok(argv[2], "/");

    while (tokens != NULL)
    {
        filename = tokens;
        tokens = strtok(NULL, "/");
    }

    // Copy upto 10 bytes from the filename
    memcpy(new_entry.file_name, filename, 10);

    // Write the new entry to file
    fseek(img, BOOT_SECTOR_SIZE + (emufs_table_entry_size * entry_idx), SEEK_SET);
    fwrite(&new_entry, emufs_table_entry_size, 1, img);

    // Read the data to be copied
    uint8_t *file_data = (uint8_t *)malloc(sizeof(uint8_t) * file_size);
    fseek(file_to_copy, 0, SEEK_SET);
    fread(file_data, sizeof(uint8_t), file_size, file_to_copy);

    // Write the file data to the offset in the img file
    fseek(img, file_offset, SEEK_SET);
    fwrite(file_data, sizeof(uint8_t), file_size, img);

    // Write the padding bytes upto the next 512 byte sector
    uint8_t *zeros = (uint8_t *)calloc(sizeof(uint8_t), diff_byte_count);
    fwrite(zeros, sizeof(uint8_t), diff_byte_count, img);
    free(zeros);
    zeros = NULL;

shutdown:
    if (g_table)
    {
        free(g_table);
        g_table = NULL;
    }

    if (file_data)
    {
        free(file_data);
        file_data = NULL;
    }

    fclose(img);
    fclose(file_to_copy);

    return ret_val;
}