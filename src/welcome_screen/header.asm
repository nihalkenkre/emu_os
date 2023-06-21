%ifndef WELCOME_SCREEN_HEADER
%define WELCOME_SCREEN_HEADER

%include "./src/prints/print_string.asm"

[bits 16]
print_header:
    push bp
    mov bp, sp

    mov si, header
    mov bl, 0x1f
    call print_string

    mov sp, bp
    pop bp

    ret

header: db '===================', 0x0a, ' Welcome to Emu OS ', 0x0d, '===================', 0x0a, 0

top_padding: dw 1
left_padding: dw 27

%endif