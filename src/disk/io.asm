%ifndef IO
%define IO

%include "./src/utils/prints.asm"

%define ENDL 0x0A, 0x0D
bx_label: db 'BX: 0x', 0
;
; Load sectors from the master hard disk into memory
; Params:
;   bl      : number of sectors to read
;   cl      : first sector number to read from
;   es:di   : The memory address to copy data to
;
load_sectors:
    pusha

    mov dx, 0x1f6
    mov al, 0xa0
    out dx, al

    mov dx, 0x1f2
    mov al, bl
    out dx, al

    mov dx, 0x1f3
    mov al, cl
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
.loop:
    in al, dx
    test al, 8
    je .loop

    mov cx, 256
    mov dx, 0x1f0
    rep insw

    dec bx
    cmp bx, 0
    ; push si
    ; push bx
    ; mov si, bx_label
    ; call print_reg
    ; call print_new_line
    ; pop bx
    ; pop si
    jnz .sector_loop

    popa

    ret

%endif