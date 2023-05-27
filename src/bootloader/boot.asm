%ifndef BOOT
%define BOOT

org 0x7c00
bits 16

start:
    jmp main

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
    mov ecx, 512                    ; Size in bytes of 1 sector
    div ecx                         ; eax contains the quotient, the number of sectors

    mov bx, ax          ; move the sector count to bx, for load_sectors
    mov cl, 2           ; number of the sector to start from, for load_sectors

    mov di, 0x7e00      ; the data will be copied to es:di - 0:0x7e00

    call load_sectors

    mov si, kernel_filename
    call get_filename_details

    cmp al, 0x1
    je .file_found
    jmp .file_not_found

.file_found:
    mov si, kernel_found
    xor cx, cx
    mov cl, [kernel_found_len]
    call puts

    jmp .halt

.file_not_found:
    mov si, kernel_not_found
    xor cx, cx
    mov cl, [kernel_not_found_len]
    call puts

    jmp .halt

.halt:
    cli
    hlt

%include "./src/disk/io.asm"

emufs_filename_len equ 10          ; table entry has 10 bytes for filename
kernel_filename: db 'kernel.bin'
kernel_found: db 'kernel found...'
kernel_found_len: db ($ - kernel_found)
kernel_not_found: db 'kernel not found...'
kernel_not_found_len: db ($ - kernel_not_found)

emufs_table_size equ 512

times 510 - ($ - $$) db 0
dw 0xAA55

%endif