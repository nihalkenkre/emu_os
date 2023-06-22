%ifndef WELCOME_SCREEN
%define WELCOME_SCREEN

%include "./src/prints/clear_screen.asm"
%include "./src/welcome_screen/header.asm"
%include "./src/welcome_screen/print_file_menu.asm"
%include "./src/io/load_sectors_16.asm"
%include "./src/chip8/run_chip8_app.asm"

[bits 16]
print_welcome_screen:
    push bp
    mov bp, sp

    mov ax, 0x0003
    int 0x10

    mov byte [char_color], 0x1f

	call clear_screen
    call print_header
    mov word [file_menu_cursor], dx
    call print_file_menu
    
    cmp byte [num_files], 0
    je .return

.keyboard_loop:
    xor ax, ax
    mov ah, 1
    int 16h

    jz .key_pressed

    jmp .keyboard_loop

.key_pressed:
    mov ah, 0
    int 16h

    cmp ah, up_arrow_scan_code
    je .up_arrow

    cmp ah, down_arrow_scan_code
    je .down_arrow

    cmp ah, enter_key_scan_code
    je .enter_key

.up_arrow:
    cmp byte [current_selection_index], 0
    je .index_to_last
    
    dec byte [current_selection_index]

    mov dx, [file_menu_cursor]
    call print_file_menu

    jmp .keyboard_loop

.index_to_last:
    mov si, num_files
    mov di, current_selection_index
    movsb

    dec byte [current_selection_index] 

    mov dx, [file_menu_cursor]
    call print_file_menu

    jmp .keyboard_loop

.down_arrow:
    xor bx, bx
    mov bl, [num_files]
    dec byte bl
    cmp bl, [current_selection_index]

    je .index_to_first

    inc byte [current_selection_index]

    mov dx, [file_menu_cursor]
    call print_file_menu

    jmp .keyboard_loop

.index_to_first:
    mov byte [current_selection_index], 0

    mov dx, [file_menu_cursor]
    call print_file_menu

    jmp .keyboard_loop

.enter_key:
    ;; calculate the addr for the table entry for current_selection_index
    ;; and load it into si

    mov si, emufs_table_addr
    add si, emufs_table_entry_size

    xor ax, ax
    mov al, [current_selection_index]
    xor bx, bx
    mov bl, emufs_table_entry_size
    mul bl

    add si, ax                          ; si pointing to entry of current_selection_index

.calculate_start_sector:
    ; calculate the start sector number to load
    ; (offset of the file / the size of 1 sector) + 1
    add si, emufs_table_entry_offset_value_offset
    lodsd

    xor ebx, ebx
    mov bx, sector_size

    xor edx, edx
    div bx
    inc eax

    mov ebx, eax                        ; start sector is in ebx


.calculate_num_sectors:
    lodsd                               ; size value in eax

    mov ecx, sector_size
    div ecx

    cmp edx, 0
    je .prepare_to_run_chip8

    inc eax

.prepare_to_run_chip8:
    mov ecx, eax                        ; number of sectors in ecx
    
    ; calculate the destination address to load the app data and store in di for load_sectors

    mov di, kernel_data_addr

    xor edx, edx
    mov dx, [kernel_data_sec_count]

    xor eax, eax
    mov ax, sector_size

    mul dx

    add di, ax                      ; addr after the kernel sectors is in di, to load the app data to
    call run_chip8_app

.return:
    mov sp, bp
    pop bp

    cli
    hlt

test: db 'TEST', 0x0a, 0
current_selection_index: db 0
num_files: db 0
file_menu_cursor: dw 0

up_arrow_scan_code equ 0x48
down_arrow_scan_code equ 0x50
enter_key_scan_code equ 0x1c

emufs_table_addr equ 0x7e00
emufs_table_entry_name_len equ 10
emufs_table_entry_size equ 18
emufs_table_entry_offset_value_offset equ emufs_table_entry_name_len
emufs_table_entry_size_value_offset equ 14

sector_size equ 512
kernel_data_addr equ 0x8000

%endif