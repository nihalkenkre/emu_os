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
    call print_file_menu

    mov sp, bp
    pop bp

    ret


test: db 'TEST', 0x0a, 0
current_selection_index: db 0

%endif