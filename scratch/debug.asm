%macro print_char 1
    mov al, %1
    call bios_print_char
%endmacro

org 0x7c00
bits 16

boot:
    jmp main
    times 3-($-$$) db 0x90

    times 59 db 0xAA

main:
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, boot
    cld
    
    mov si, sp
    mov cx, main-boot
    mov dx, 8

.tblloop:
    cmp dx, 8
    jne .procbyte

    print_char 0x0D
    print_char 0x0A

    mov ax, si

    call print_word_hex

    print_char ':'
    print_char ' '
    xor dx, dx

.procbyte:
    lodsb 
    call print_byte_hex
    print_char ' '
    inc dx
    dec cx
    jnz .tblloop

    cli
.end:
    hlt
    jmp .end

bios_print_char:
    push bx
    xor bx, bx
    mov ah, 0x0E
    int 0x10
    pop bx
    ret

print_word_hex:
    xchg al, ah
    call print_byte_hex
    xchg al, ah
    call print_byte_hex
    ret

print_byte_hex:
    push bx
    push cx
    push ax

    lea bx, [.table]

    mov ah, al
    and al, 0x0F
    mov cl, 4
    shr ah, cl
    xlat
    xchg ah, al
    xlat

    xor bx, bx
    mov ch, ah
    mov ah, 0x0E
    int 0x10
    mov al, ch
    int 0x10

    pop ax
    pop cx
    pop bx
    ret

.table: db "0123456789ABCDEF", 0

times 510-($-$$) db 0
dw 0xAA55