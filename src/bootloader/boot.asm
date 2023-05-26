org 0x7c00
bits 16

start:
    jmp main

main:
    call load_sectors

    call 0x7e00

    cli
    hlt

load_sectors:
    pusha

    mov dx, 0x1f6
    mov al, 0xa0
    out dx, al

    mov bl, 50             ; number of sectors

    mov dx, 0x1f2
    mov al, bl
    out dx, al

    mov dx, 0x1f3
    mov al, 2               ; Start sector number
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

    xor ax, ax
    mov es, ax
    mov di, 0x7e00

.sector_loop:
.loop:
    in al, dx
    test al, 8
    je .loop

    mov cx, 256
    mov dx, 0x1f0
    rep insw

    dec bx
    cmp bx, 0
    jnz .sector_loop

    popa

    ret

.halt:
    jmp .halt

times 510 - ($ - $$) db 0
dw 0xAA55