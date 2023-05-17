#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>

typedef struct BPB
{
    uint8_t jump[3];
    uint8_t oem_name[8];
    uint16_t bytes_per_sector;
    uint8_t sectors_per_cluster;
    uint16_t reserved_sectors;
    uint8_t fat_count;
    uint16_t boot_dir_entry_count;
    uint16_t num_sectors;
    uint8_t media_type;
    uint16_t fat_sector_count;
    uint16_t sectors_per_track;
    uint16_t head_count;
    uint32_t hidden_sector_count;
    uint32_t large_sector_count;
    uint8_t drive_number;
    uint8_t reserved;
    uint8_t signature;
    uint32_t volume_id;
    uint8_t volume_label[11];
    uint8_t file_system_type[8];
} __attribute__((packed)) BPB;

BPB g_bpb;

int read_boot_sector(FILE *disk)
{
    return fread(&g_bpb, sizeof(g_bpb), 1, disk) > 0;
}

int main(int argc, char **argv)
{
    printf("Hello Fat12\n");

    if (argc < 3)
    {
        printf("Syntax: %s <disk_image> <file_name>\n", argv[0]);
        return -1;
    }

    FILE *disk = fopen(argv[1], "rb");

    if (!disk)
    {
        fprintf(stderr, "Cannot open disk image: %s\n", argv[1]);
        return -1;
    }

    if (!read_boot_sector(disk))
    {
        printf("Could not read boot sector\n");

        goto shutdown;
    }

shutdown:
    fclose(disk);

    printf("Byte Fat12\n");
    return 0;
}