%ifndef BOOT
%define BOOT

org 0x7c00
bits 16

start:
    jmp main

; %include "./src/io/load_sectors_16.asm"
; %include "./src/io/get_filename_details_16.asm"
%include "./src/prints/print_string_boot.asm"

; arg0: ptr to filename_details struct      bp + 4
; arg1: mem addr for kernel to be loaded        bp + 6
;
; ret: 1 if successfully loaded, 0 otherwise    ax
load_kernel_to_mem:
    push bp
    mov bp, sp

    ; bp - 2 = return value
    ; bp - 4 = bx
    ; bp - 6 = num sectors
    sub sp, 6                      ; allocate local variable space

    mov word [bp - 2], 1            ; return value
    mov [bp - 4], bx                ; save bx

    mov bx, [bp + 4]                ; ptr to filename_details struct
    add bx, 5                       ; jump over file_found and file_offset 

    mov eax, [bx]                   ; file_size in eax
    mov cx, sector_size
    xor dx, dx
    div cx

    cmp dx, 0                      ; if edx != 0, it will be between 0 and 512, so load 1 more sector
    je .calculate_start_sector

    inc ax

.calculate_start_sector:
    mov [bp - 6], ax                ; num sectors
    
    sub bx, 4                       ; file offset
    mov ax, [bx]                    ; file offset

    mov cx, sector_size
    xor dx, dx
    div cx                          ; start sector in ax

    inc ax

    push word 0x8000
    push word [bp - 6]              ; num sectors
    push ax                         ; start sector
    call load_sectors

.shutdown:
    mov bx, [bp - 6]                ; restore bx
    mov ax, [bp - 2]                ; return value

    leave
    ret 4

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

    ; sp - 2 = esi
    ; sp - 4 = edi
    ; sp - 6 = ebx
    sub sp, 6                      ; allocate local variable space

    mov [bp - 2], si               ; save si
    mov [bp - 4], di               ; save di
    mov [bp - 6], bx              ; save bx

    mov di, [bp + 6]        ; ptr to emufs table
    mov si, [bp + 8]        ; ptr to file name

    xor ecx, ecx
.filename_loop:
    mov cx, emufs_filename_len
    repe cmpsb

    jcxz .file_found

.file_not_found:
    mov bp, [bp + 4]                ; ptr to return struct
    mov [bx], byte 0                ; file not found

    jmp .shutdown

.file_found:
    mov bx, [bp + 4]                ; ptr to return struct
    mov [bx], byte 1                ; file found

    inc bx                          ; point to file offset

    mov eax, [di]                   ; file offset
    mov [bx], dword eax

    add bx, 4                       ; point to file size
    add di, 4                      ; point to file size

    mov eax, [di]                   ; file size
    mov [bx], dword eax

.shutdown:
    mov bx, [bp - 6]              ; restore bx
    mov di, [bp - 4]               ; restore di
    mov si, [bp - 2]               ; restore si

    mov ax, [bp + 4]        ; ptr to return struct

    leave
    ret 6

; arg0: first sector number to read from        bp + 4
; arg1: number of sectors to read               bp + 6
; arg2: mem addr to load sectors to             bp + 8
load_sectors:
    push bp
    mov bp, sp

    ; bp - 2 = di
    sub sp, 2                       ; allocate locate variable space

    mov [bp - 2], di               ; save edi

    mov dx, 0x1f6
    mov al, 0xa0
    out dx, al

    mov dx, 0x1f2
    movzx eax, word [bp + 6]        ; the number of sectors to read
    out dx, al

    mov dx, 0x1f3
    movzx eax, word [bp + 4]        ; the first sector number to read
    out dx, al

    mov dx, 0x1f4
    xor al, al                      ; high cylinder value 0
    out dx, al

    mov dx, 0x1f5
    xor al, al                      ; Low cylinder value 0
    out dx, al

    mov dx, 0x1f7
    mov al, 0x20                    ; 0x20 for read operation
    out dx, al

    mov di, [bp + 8]                ; the mem addr to copy to

.loop:
    in al, dx
    test al, 8
    je .loop

    mov cx, 256                     ; 256 words in a sector
    mov dx, 0x1f0
    rep insw

    dec word [bp + 6]               ; number of sectors
    jnz .loop

.shutdown:

    mov di, [bp - 2]                ; restore di

    leave

    ret 6

main:
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov si, ax
    mov di, ax
    
    cld

    mov sp, 0x7c00                      ; init stack pointer to the code start
    mov bp, sp
    
    ; bp - 9 = filename_details  struct
    ; bp - 10 = 1 byte padding to make it an even number
    sub sp, 10                          ; allocate local variable space

    ; Load the emufs table to 0x7e00
    ; Calculate the number of sectors to load.
    ; Divide the emufs table size by the size of 1 sector
    xor dx, dx
    mov ax, emufs_table_size            ; Size in bytes of the emufs table to load
    mov cx, sector_size                 ; Size in bytes of 1 sector
    div cx                              ; always divides the value in edx:eax by the operand. quotient in eax, remainder in edx

    mov edi, 0xdeadbabe
    push word 0x7e00                    ; the dest mem addr
    push ax                             ; the number of sectors to load
    push word 2                         ; the sector number to start from
    call load_sectors

    push kernel_filename                ; ptr to filename
    push word 0x7e00                    ; ptr to emufs table
    mov ax, bp
    sub ax, 9                           ; ptr to filename_details struct
    push ax
    call get_filename_details

    cmp byte [bp - 9], 1                ; file found ?
    je .file_found
    jmp .file_not_found

.file_found:
    ; Load the kernel data to 0x8000
    ; Calculate the number of sectors to load

    push word 0x8000
    mov ax, bp
    sub ax, 9                           ; ptr to filename_details struct
    push ax
    call load_kernel_to_mem

    cmp eax, 0                          ; did kernel load fail ?
    je .halt

    leave
    jmp 0:0x8000

    jmp .halt


.file_not_found:
    mov si, kernel_not_found
    call print_string_boot

    jmp .halt

.halt:
    leave

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