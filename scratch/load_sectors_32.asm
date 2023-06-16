%ifndef LOAD_SECTORS_32
%define LOAD_SECTORS_32

;---------------------------------
; TODO: 28 bit PIO and 48 bit PIO |
;---------------------------------
;
; Load sectors from the master hard disk into memory
; Params:
;   bl      : first sector number to read from
;   cl      : number of sectors to read
;   es:di   : The memory address to copy data to
;
[bits 32]
load_sectors:
    push ebp
    mov ebp, esp

    push eax
    push ebx
    push ecx                ; push the number of sectors for later use
    push edx

    mov dx, 0x1f6
    mov al, 0xa0
    out dx, al

    mov dx, 0x1f2
    mov al, cl              ; the number of sectors to read 
    out dx, al

    mov dx, 0x1f3
    mov al, bl              ; the first sector number to read
    out dx, al

    mov dx, 0x1f4
    xor al, al              ; high cylinder value 0
    out dx, al

    mov dx, 0x1f5
    xor al, al              ; low cylinder value 0
    out dx, al

    mov dx, 0x1f7
    mov al, 0x20            ; 0x20 for read operation
    out dx, al

.sector_loop:
    push ecx                ; push the number of sectors for later comparision

.loop:
    in al, dx
    test al, 8
    je .loop

    mov ecx, 256
    mov edx, 0x1f0
    rep insw

    pop ecx                 ; pop the number of sectors for comparison

    dec ecx
    jnz .sector_loop

.return:
    pop edx
    pop ecx                 ; pop the number of sectors for later use
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp

    ret

%endif