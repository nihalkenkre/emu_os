%ifndef RUN_CHIP8
%define RUN_CHIP8

[bits 16]
clear_screen_graphics:
    push bp
    mov bp, sp

    push ax
    push es
    push di

    mov ax, 0xa000
    mov es, ax
    mov di, 0x0000

    add di, 320 * 20

    mov cx, 320 * 160
    mov ax, 0x6b
    rep stosb

    pop di
    pop es
    pop ax

    mov sp, bp
    pop bp

    ret

;
; Runs the Chip8 program located in memory
; Params:
;   di: program addr
;   
[bits 16]
run_chip8_app:
    push bp
    mov bp, sp

    mov ax, 0x0013                        ; 320x200 graphics mode 
    int 0x10

    call clear_screen_graphics

.keyboard_loop:
    xor ax, ax
    mov ah, 1
    int 16h

    jz .key_pressed

    jmp .keyboard_loop

.key_pressed:
    mov ah, 0
    int 16h

    cmp ah, esc_scan_code
    je .esc_key

.esc_key:
    jmp print_welcome_screen

    mov sp, bp
    pop bp

    ret


esc_scan_code equ 0x01

%endif