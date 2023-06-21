%ifndef WELCOME_SCREEN
%define WELCOME_SCREEN

%include "./src/prints/clear_screen.asm"
%include "./src/welcome_screen/header.asm"
%include "./src/welcome_screen/print_file_menu.asm"

[bits 16]
print_welcome_screen:
    push bp
    mov bp, sp

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

.return:
    mov sp, bp
    pop bp

    ret

test: db 'TEST', 0x0a, 0
current_selection_index: db 0
num_files: db 0
file_menu_cursor: dw 0

up_arrow_scan_code equ 0x48
down_arrow_scan_code equ 0x50

%endif