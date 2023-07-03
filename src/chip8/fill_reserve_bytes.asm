%ifndef FILL_RESERVE_BYTES
%define FILL_RESERVE_BYTES

[bits 16]
fill_reserve_bytes:
    push bp
    mov bp, sp

    mov di, chip8_memory

    push ax
    push cx

    ; 0
    mov al, 0xf0
    stosb
    mov al, 0x90
    stosb
    mov al, 0x90
    stosb
    mov al, 0x90
    stosb
    mov al, 0xf0
    stosb

    ; 1
    mov al, 0x20
    stosb
    mov al, 0x60
    stosb
    mov al, 0x20
    stosb
    mov al, 0x20
    stosb
    mov al, 0x70
    stosb

    ; 2
    mov al, 0xf0
    stosb
    mov al, 0x10
    stosb
    mov al, 0xf0
    stosb
    mov al, 0x80
    stosb
    mov al, 0xf0
    stosb

    ; 3
    mov al, 0xf0
    stosb
    mov al, 0x10
    stosb
    mov al, 0xf0
    stosb
    mov al, 0x10
    stosb
    mov al, 0xf0
    stosb

    ; 4
    mov al, 0x90
    stosb
    mov al, 0x90
    stosb
    mov al, 0xf0
    stosb
    mov al, 0x10
    stosb
    mov al, 0x10
    stosb

    ; 5
    mov al, 0xf0
    stosb
    mov al, 0x80
    stosb
    mov al, 0xf0
    stosb
    mov al, 0x10
    stosb
    mov al, 0xf0
    stosb

    ; 6
    mov al, 0xf0
    stosb
    mov al, 0x80
    stosb
    mov al, 0xf0
    stosb
    mov al, 0x90
    stosb
    mov al, 0xf0
    stosb

    ; 7
    mov al, 0xf0
    stosb
    mov al, 0x10
    stosb
    mov al, 0x20
    stosb
    mov al, 0x40
    stosb
    mov al, 0x40
    stosb

    ; 8
    mov al, 0xf0
    stosb
    mov al, 0x90
    stosb
    mov al, 0xf0
    stosb
    mov al, 0x90
    stosb
    mov al, 0xf0
    stosb

    ; 9
    mov al, 0xf0
    stosb
    mov al, 0x90
    stosb
    mov al, 0xf0
    stosb
    mov al, 0x10
    stosb
    mov al, 0xf0
    stosb

    ; A
    mov al, 0xf0
    stosb
    mov al, 0x90
    stosb
    mov al, 0xf0
    stosb
    mov al, 0x90
    stosb
    mov al, 0x90
    stosb

    ; B
    mov al, 0xe0
    stosb
    mov al, 0x90
    stosb
    mov al, 0xf0
    stosb
    mov al, 0x90
    stosb
    mov al, 0xe0
    stosb

    ; C
    mov al, 0xf0
    stosb
    mov al, 0x80
    stosb
    mov al, 0x80
    stosb
    mov al, 0x80
    stosb
    mov al, 0xf0
    stosb

    ; D
    mov al, 0xe0
    stosb
    mov al, 0x90
    stosb
    mov al, 0x90
    stosb
    mov al, 0x90
    stosb
    mov al, 0xe0
    stosb

    ; E
    mov al, 0xf0
    stosb
    mov al, 0x80
    stosb
    mov al, 0xf0
    stosb
    mov al, 0x80
    stosb
    mov al, 0xf0
    stosb

    ; F
    mov al, 0xf0
    stosb
    mov al, 0x80
    stosb
    mov al, 0xf0
    stosb
    mov al, 0x80
    stosb
    mov al, 0x80
    stosb

    pop cx
    pop ax

    mov sp, bp
    pop bp

    ret

%endif