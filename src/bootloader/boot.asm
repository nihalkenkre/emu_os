org 0x7c00
bits 16

start:
    jmp main

main:
    mov dx, 0x1f6
    mov al, 0xa0
    out dx, al

    mov dx, 0x1f2
    mov al, 1
    out dx, al

    mov dx, 0x1f3
    mov al, 2
    out dx, al

    mov dx, 0x1f4
    xor al, al
    out dx, al

    mov dx, 0x1f5
    xor al, al
    out dx, al

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

.loop:
    in al, dx
    test al, 8
    je .loop

    xor ax, ax
    mov es, ax
    mov di, 0x7e00
    mov cx, 256
    mov dx, 0x1f0
    rep insw

    jmp 0x7e00

    cli
    hlt

.halt:
    jmp .halt

times 510 - ($ - $$) db 0
dw 0xAA55