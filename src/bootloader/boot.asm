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

    mov sp, 0x7c00

    ; Load the emufs table to 0x7e00
    mov bx, 8           ; number of sectors to load. The emufs table is 4096 bytes, each sector is 512 bytes
    mov cl, 2           ; number of the sector to start from

    mov di, 0x7e00      ; the data will be copied to es:di - 0:0x7e00

    call load_sectors

    ;; Look for the table entry with name kernel.bin
    ; find number of table entries in table
    xor edx, edx
    mov eax, 4096       ; emufs table total size
    mov ecx, 14         ; size of table entry: 10 byte file name + 2 byte offset from disk start + 2 byte size
    div ecx             ; always divides the value in edx:eax by the operand. quotient in eax, remainder in edx

    ; eax contains the number of table entries
    ; Loop through table entries to find entry with kernel.bin

    mov ecx, eax        ; number of table entries to ecx

.table_loop:
    push ecx

.filename_loop:
    mov si, kernel_filename
    repe cmpsb
    jz .found_kernel

    pop ecx
    dec ecx
    cmp ecx, 0
    jnz .table_loop

    jmp .kernel_not_found

.found_kernel:
    mov si, kernel_found
    mov cl, byte [kernel_found_len]
    call puts

    cli
    hlt

.kernel_not_found:
    mov si, kernel_not_found
    mov cl, byte [kernel_not_found_len]
    call puts
    
    cli
    hlt

.halt:
    jmp .halt

%include "./src/disk/io.asm"

kernel_filename: db 'kernel.bin'
emufs_filename_len: db 10          ; table entry has 10 bytes for filename
kernel_found: db 'kernel found...'
kernel_found_len: db ($ - kernel_found)
kernel_not_found: db 'kernel not found...'
kernel_not_found_len: db ($ - kernel_not_found)

times 510 - ($ - $$) db 0
dw 0xAA55

%endif