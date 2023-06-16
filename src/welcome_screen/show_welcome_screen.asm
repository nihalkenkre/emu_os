%ifndef SHOW_WELCOME_SCREEN
%define SHOW_WELCOME_SCREEN

%include "./src/vbe/draw/clear_screen.asm"
%include "./src/welcome_screen/print_header.asm"
%include "./src/welcome_screen/print_file_menu.asm"

[bits 32]
show_welcome_screen:
    push ebp
    mov ebp, esp

    call clear_screen
    call print_header
    call print_file_menu
    call update_selection

    mov esp, ebp
    pop ebp

    ret

%endif