%ifndef BOOT
%define BOOT

org 0x7c00
bits 16

start:
    jmp main

%include "./src/io/load_sectors_16.asm"
%include "./src/io/get_filename_details_16.asm"
%include "./src/prints/print_string.asm"

main:
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov si, ax
    mov di, ax
    
    cld

    mov sp, 0x7c00      ; init stack pointer to the code start

    ; Load the emufs table to 0x7e00
    ; Calculate the number of sectors to load.
    ; Divide the emufs table size by the size of 1 sector
    xor edx, edx
    mov eax, emufs_table_size       ; Size in bytes of the emufs table to load
    mov ecx, sector_size            ; Size in bytes of 1 sector
    div ecx                         ; always divides the value in edx:eax by the operand. quotient in eax, remainder in edx

    mov bl, 2           ; number of the sector to start from, for load_sectors
    mov cx, ax          ; move the sector count to bx, for load_sectors

    mov di, 0x7e00      ; the data will be copied to es:di - 0:0x7e00

    push di
    call load_sectors
    pop di

    mov si, kernel_filename
    call get_filename_details

    cmp al, 0x1
    je .file_found
    jmp .file_not_found

.file_found:
    ; Load the kernel data to 0x8000
    ; Calculate the number of sectors to load

.calculate_num_sectors:
    ; cx contains the size of the file,
    xor dx, dx
    xor ax, ax

    mov ax, cx            ; move the size of the file to ax
    mov cx, sector_size
    div cx                 ; always divides the value in edx:eax by the operand. quotient in eax, remainder in edx

    cmp dx, 0
    je .calculate_start_sector

    inc ax                 ; Assumption is if dx is not 0, it will be between 0 and 512, so need to load one more sector

.calculate_start_sector:
    push ax                ; push number of sectors to load for later use

    ; calculate the start sector number to load
    ; (offset of the file / the size of 1 sector) + 1
    xor dx, dx
    xor ax, ax

    mov ax, bx            ; move the offset of the file to ax
    mov cx, sector_size
    div cx                 ; always divides the value in dx:ax by the operand. quotient in ax, remainder in dx

    inc ax                 ; + 1

    mov bx, ax            ; move start sector to ebx for load_sectors
    pop ax                ; get back the number of sectors
    mov cx, ax            ; move the number of sectors to ecx for load_sectors

    mov di, 0x8000        ; load the file data to 0x8000

.load_sectors:
    call load_sectors

    jmp 0:0x8000          ; far jump to kernel. far jump resets the segment registers

    jmp .halt

.file_not_found:
    mov si, kernel_not_found
    call print_string

    jmp .halt

.halt:
    cli
    hlt

emufs_filename_len equ 10          ; table entry has 10 bytes for filename
emufs_table_size equ 512
sector_size equ 512

kernel_filename: db 'kernel.bin'
kernel_not_found: db 'kernel not found...'


times 510 - ($ - $$) db 0
dw 0xAA55

%endif