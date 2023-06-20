%ifndef WELCOME_SCREEN
%define WELCOME_SCREEN

%include "./src/prints/clear_screen.asm"
%include "./src/welcome_screen/header.asm"
%include "./src/prints/cursor_position.asm"

[bits 16]
print_welcome_screen:
    push bp
    mov bp, sp

	call clear_screen
    call print_header

    mov sp, bp
    pop bp

    ret

%endif