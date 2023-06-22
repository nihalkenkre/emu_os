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

[bits 16]
fill_reserve_bytes:
    push bp
    mov bp, sp

    push ax
    push cx
    push di                 ; save initial di for later padding calculations

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

    ; increment di to the 512 boundary
    ; first find the difference of the current di from initial di

    pop cx                  ; initial di is in cx
    mov ax, di              ; current di is in ax
    sub ax, cx              ; ax = cx - ax

    ; subtract the remainder from the sector size and add the diff
    ; to the current di
    mov cx, sector_size
    sub cx, ax              ; cx = ax -cx

    add di, cx              ; di at the 512 boundary

    pop cx
    pop ax

    mov sp, bp
    pop bp

    ret

;
; Fetches the next 2 byte opcode from the 'chip8' memory and executes it
;
; Params:
;   si: ptr to memory
;
[bits 16]
execute_next_opcode:
    push bp
    mov bp, sp

    push ax

    lodsw               ; opcode is in ax

    push ax
    shr ax, 12          ; shift right by 12 to get the 'first' nibble

    cmp al, 0
    je .first_0

    cmp al, 1
    je .first_1

    jmp .return

.first_0:
    pop ax
    
    cmp al, 0xe0
    je ._00e0

    cmp al, 0xee
    je ._00ee

._00e0:
    call clear_screen_graphics
    add byte [chip8_pc], 2

._00ee:


.return:
    pop ax

    mov sp, bp
    pop bp

    ret

;
; Runs the Chip8 program located in memory
; Params:
;   bx: start sector
;   cx: sector count
;
;   di: addr where the interpreter starts, first 512 reserved. font data is here
;       app data can be stored at di + 512
;   
[bits 16]
run_chip8_app:
    push bp
    mov bp, sp

    mov [chip8_memory], di
    call fill_reserve_bytes
    mov [chip8_pc], di
    call load_sectors

    mov ax, 0x0013                        ; 320x200 graphics mode 
    int 0x10

    mov ax, 0xa000
    mov es, ax

    mov di, 320 * 100 + 160

    mov si, [chip8_memory]

.timer_loop:                                ; TIMER HACK !!!
    mov ecx, 0xffffff

.timer_wait:
    dec ecx
    jnz .timer_wait

    call execute_next_opcode

.keyboard_loop:
    xor ax, ax
    mov ah, 1
    int 16h

    jnz .key_pressed

    jmp .timer_loop

.key_pressed:
    xor ax, ax
    mov ah, 0
    int 16h

    cmp ah, esc_scan_code
    je .esc_key

    jmp .timer_loop

.esc_key:
    jmp print_welcome_screen

    mov sp, bp
    pop bp

    ret


esc_scan_code equ 0x01

sector_size equ 512

chip8_memory: dw 0
chip8_pc: dw 0
chip8_stack: times 16 dw 0
chip8_sp: dw 0

%endif