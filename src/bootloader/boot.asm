%ifndef BOOT
%define BOOT

org 0x7c00
bits 16

start:
    jmp main

%include "./src/disk/io.asm"

main:
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov si, ax
    mov di, ax

    mov sp, 0x7c00

    mov bx, 8           ; number of sectors to load. The emufs table is 4096 bytes, each sector is 512 bytes
    mov cl, 2           ; number of the sector to start from

    mov es, ax
    mov di, 0x7e00      ; the data will be copied to es:di - 0:0x7e00

    call load_sectors

    cli
    hlt

.halt:
    jmp .halt


times 510 - ($ - $$) db 0
dw 0xAA55

%endif