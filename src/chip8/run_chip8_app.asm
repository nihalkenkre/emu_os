%ifndef RUN_CHIP8
%define RUN_CHIP8

;
; Runs the Chip8 program located in memory
;   di: program addr
;

[bits 16]
run_chip8_app:
    push bp
    mov bp, sp

    mov ax, 0x0013
    int 0x10

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