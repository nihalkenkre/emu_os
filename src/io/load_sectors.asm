%ifndef LOAD_SECTORS
%define LOAD_SECTORS

;
; Load sectors from the master hard disk into memory
; Params:
;   bl      : first sector number to read from
;   cl      : number of sectors to read
;   es:di   : The memory address to copy data to
;
[bits 16]
load_sectors:
    push bp
    mov bp, sp

    push ax
    push bx
    push cx                 ; pop the number of sectors for later use
    push dx

    mov dx, 0x1f6
    mov al, 0xa0
    out dx, al

    mov dx, 0x1f2
    mov al, cl
    out dx, al

    mov dx, 0x1f3
    mov al, bl
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

.sector_loop:
    push cx                 ; push the number of sectors for later comparision
.loop:
    in al, dx
    test al, 8
    je .loop

    mov cx, 256
    mov dx, 0x1f0
    rep insw

    pop cx                  ; pop the number of sectors for comparison

    dec cx

    jnz .sector_loop

.return:
    pop dx
    pop cx                  ; pop the number of sectors for later use
    pop bx
    pop ax

    mov sp, bp
    pop bp

    ret

%endif