%ifndef BOOT
%define BOOT

org 0x7c00
bits 16

start:
    jmp main

; %include "./src/io/load_sectors_16.asm"
; %include "./src/io/get_filename_details_16.asm"
%include "./src/prints/print_string_boot.asm"

; struct filename_details
; { 
;   file_found: byte 1 if file found, 0 otherwise
;   file_offset: dword
;   file_size: dword    
; }

; arg0: ptr to return struct                    bp + 4
; arg1: ptr to emufs table                      bp + 6
; arg2: ptr to file name                        bp + 8
;
; ret: addr to the struct obj passed by caller  ax
get_filename_details:
    push bp
    mov bp, sp

    ; sp - 4 = esi
    ; sp - 8 = edi
    ; sp - 12 = ebx
    sub sp, 12                      ; allocate local variable space

    mov [bp - 4], esi               ; save esi
    mov [bp - 8], edi               ; save edi
    mov [bp - 12], ebx              ; save ebx

    movzx edi, word [bp + 6]        ; ptr to emufs table
    movzx esi, word [bp + 8]        ; ptr to file name

.filename_loop:
    mov cx, emufs_filename_len
    repe cmpsb
    jecxz .file_found

.file_found:
    mov bx, [bp + 4]                ; ptr to return struct
    mov [bx], byte 1                     ; file found
    inc bx

    mov eax, [di]                    ; file offset
    mov [bx], dword eax

    add bx, 4
    add edi, 4

    mov eax, [di]
    mov [bx], dword eax

.shutdown:
    add sp, 12                      ; free local variable space
    add sp, 6                       ; free arg stack

    mov ebx, [bp - 12]              ; restore ebx
    mov edi, [bp - 8]               ; restore edi
    mov esi, [bp - 4]               ; restore esi

    movzx eax, word [bp + 4]        ; ptr to return struct

    leave
    ret

; arg0: first sector number to read from        ebp + 4
; arg1: number of sectors to read               ebp + 6
; arg2: mem addr to load sectors to             ebp + 8
load_sectors:
    push bp
    mov bp, sp

    ; bp - 4 = edi
    ; bp - 11 = file_name_details struct
    ; bp - 12 = 1 byte padding to make it an even number
    sub sp, 12              ; allocate locate variable space

    mov [bp - 2], edi      ; save di

    mov dx, 0x1f6
    mov al, 0xa0
    out dx, al

    mov dx, 0x1f2
    movzx eax, byte [bp + 6]              ; the number of sectors to read
    out dx, al

    mov dx, 0x1f3
    movzx eax, byte [bp + 4]              ; the first sector number to read
    out dx, al

    mov dx, 0x1f4
    xor al, al              ; high cylinder value 0
    out dx, al

    mov dx, 0x1f5
    xor al, al              ; Low cylinder value 0
    out dx, al

    mov dx, 0x1f7
    mov al, 0x20            ; 0x20 for read operation
    out dx, al

    movzx edi, word [bp + 8]     ; the mem addr to copy to

.sector_loop:

.loop:
    in al, dx
    test al, 8
    je .loop

    mov cx, 256             ; 256 words in a sector
    mov dx, 0x1f0
    rep insw

    dec word [bp + 6]       ; number of sectors
    jnz .sector_loop

.shutdown:
    add sp, 12              ; free local variable space
    add sp, 6              ; free arg stack

    movzx edi, word [bp - 2]      ; restore di

    leave
    ret

main:
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov si, ax
    mov di, ax
    
    cld

    mov sp, 0x7c00                      ; init stack pointer to the code start
    
    ; sp - 9 = filename_details  struct
    ; sp - 10 = 1 byte padding to make it an even number
    sub sp, 10                          ; allocate local variable space

    ; Load the emufs table to 0x7e00
    ; Calculate the number of sectors to load.
    ; Divide the emufs table size by the size of 1 sector
    xor dx, dx
    mov ax, emufs_table_size            ; Size in bytes of the emufs table to load
    mov cx, sector_size                 ; Size in bytes of 1 sector
    div cx                              ; always divides the value in edx:eax by the operand. quotient in eax, remainder in edx

    push word 0x7e00                    ; the dest mem addr
    push ax                             ; the number of sectors to load
    push word 2                         ; the sector number to start from
    call load_sectors

    push kernel_filename                ; ptr to filename
    push word 0x7e00                    ; ptr to emufs table
    push sp
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

    add sp, 10              ; free local variable space
    jmp 0:0x8000          ; far jump to kernel. far jump resets the segment registers

    jmp .halt

.file_not_found:
    mov si, kernel_not_found
    call print_string_boot

    jmp .halt

.halt:
    add sp, 10              ; free local variable space
    cli
    hlt

emufs_filename_len equ 10          ; table entry has 10 bytes for filename
emufs_table_size equ 512
emufs_table_entry_size equ 18
emufs_max_table_entry_count equ emufs_table_size / emufs_table_entry_size
sector_size equ 512
emufs_table_sector_count equ emufs_table_size / sector_size

kernel_filename: db 'kernel.bin'
kernel_not_found: db 'kernel not found...', 0x0a, 0x0d, 0


times 510 - ($ - $$) db 0
dw 0xAA55

%endif