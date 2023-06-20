%ifdef VBE
%ifndef SHOW_WELCOME_SCREEN
%define SHOW_WELCOME_SCREEN

%include "./src/vbe/draw/clear_screen_vbe.asm"
%include "./src/welcome_screen/print_header.asm"
%include "./src/welcome_screen/print_file_menu.asm"
%include "./src/welcome_screen/update_file_menu_selection.asm"

[bits 32]
show_welcome_screen:
    push ebp
    mov ebp, esp

    call clear_screen_vbe
    call print_header
    call print_file_menu
    call update_file_menu_selection

    mov esp, ebp
    pop ebp

    ret

%endif
%endif