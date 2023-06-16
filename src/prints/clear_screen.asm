%ifndef CLEAR_SCREEN
%define CLEAR_SCREEN

[bits 16]
clear_screen:
    push bp
    mov bp, sp

    push es

    mov ax, 0xb000
    mov es, ax
    mov di, 0x8000

    mov cx, 80 * 25
    mov ax, 0x1000

    rep stosw

    pop es

    mov sp, bp
    pop bp

    ret

%endif