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

;
; Fetches the next 2 byte opcode from the 'chip8' memory and executes it
; Chip8 is Big Endian and x86 is Little Endian
; So the higher bytes of the opcode are stored as the lower bytes in the memory addr
;
; Params:
;   si: ptr to memory
;
[bits 16]
execute_next_opcode:
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

    mov bx, [chip8_pc]
    mov ax, [bx]                        ; opcode is in ax
    ror ax, 8                           ; converting the 2 byte x86 Little Endian data to Chip8 Big Endian data

    ;; Check the most significant nibble of the opcode to determine
    ;; the functionality required
    push ax                             ; this value will be needed to check the complete opcode
    and ax, 0xf000
    shr ah, 4                           ; this will leave the most significant nibble in ah

    cmp ah, 0
    je .first_0

    cmp ah, 1
    je .first_1

    cmp ah, 2
    je .first_2

    cmp ah, 6
    je .first_6

    cmp ah, 0xa
    je .first_a

    cmp ah, 0xd
    je .first_d

    add word [chip8_pc], 2

    jmp .return

.first_0:
    pop ax                              ; retrieve the full opcode
    
    cmp al, 0xe0
    je ._00e0

    cmp al, 0xee
    je ._00ee

    jmp .return

._00e0:
    call clear_screen_graphics
    add word [chip8_pc], 2

    jmp .return

._00ee:
    mov bx, [chip8_sp]                  ; sp is in bx
    mov ax, [chip8_stack + bx]
    mov [chip8_pc], ax

    dec byte [chip8_sp]

    jmp .return

.first_1:
    pop ax                              ; retrieve the full opcode

    and ax, 0x0fff
    mov [chip8_pc], ax

    jmp .return

.first_2:
    pop ax

    and ax, 0x0fff                      ; filter out the new pc

    mov cx, [chip8_pc]                  ; mov pc value to cx
    add cx, 2                           ; add 2 to the pc
    mov bx, [chip8_sp]                  ; mov sp value to bx
    mov [chip8_stack + bx], cx          ; mov the pc value to the stack

    inc byte [chip8_sp]                 ; increment sp since we pushed somethig on the stack

    mov [chip8_pc], ax                  ; mov new pc to the pc
    
    jmp .return

.first_6:
    pop ax                              ; retrieve the full opcode

    and ah, 0x0f
    mov bl, ah

    mov [chip8_V + bx], al
    add word [chip8_pc], 2

    jmp .return

.first_a:
    pop ax                              ; retrieve the full opcode

    and ax, 0x0fff
    mov [chip8_I], ax

    add word [chip8_pc], 2

    jmp .return

.first_d:
    pop ax                              ; retrieve the full opcode
    
    and ax, 0x0fff                      ; *XYN

    push ax                             ; save xyn so we can extract x y n
    and al, 0x0f
    xor cx, cx
    mov cl, al                          ; cl contains n
    pop ax

    push ax                             ; save xyn so we can extract x y n
    and al, 0xf0
    shr al, 4
    xor bx, bx
    mov bl, al                          ; bl contains y
    pop ax

    push ax                             ; save xyn so we can extract x y n
    and ah, 0x0f
    xor dx, dx
    mov dl, ah                          ; dl contains x
    pop ax

    ; Get the y co-ordinate, and store it in bl
    mov bl, [chip8_V + bx]
    and bl, 31

    mov byte [chip8_V + 0xa], 0

    mov ch, 0                           ; this will be the index of the counter, going to cl

    .n_loop:
        ; Get the Nth row byte into ax
        ; row = chip8_memory[chip8_I + n]
        
        ; First calculate the chip_I + n
        mov ax, [chip8_I]

        push cx
        xchg ch, cl 
        xor ch, ch
        add ax, cx                          ; ax containx chip8_I + n

        pop cx

        ; mov ax to bx 
        ; since bx can be used as an offset
        push bx
        mov bx, ax
        xor ax, ax
        mov al, [chip8_memory + bx]        ; al contains the Nth row byte
        ; ror al, 4                          ; x86 little endian to chip8 big endian
        pop bx
        
        push cx                            ; cx will be used for row bittest

        mov cx, 7                          ; bit index

        ; al contains the Nth row byte, chip8_display_buffer contains the bytes 
        ;    currently in the display buffer
        ; XOR the individual bits of al with the bits starting at chip8_display_buffer[x][y]
        ;    and store the result in chip8_display_buffer[x][y]
        .row_loop:
        .row_byte_compare:                         ; check if row byte bit at cx is set
            bt ax, cx
        .display_compare:
            push dx
            mov dl, [chip8_display_buffer + dx]
            mul dl,
            bt dx, cx
            pop dx

            jz .row_loop_end

            dec cx
            jmp .row_loop

        .row_loop_end:

        pop cx

        inc byte ch
        cmp ch, cl
        jne .n_loop

    add word [chip8_pc], 2

    jmp .return

.return:
    pop dx
    pop cx
    pop bx
    pop ax

    mov sp, bp
    pop bp

    ret

;
; Loads the Chip8 program into memory and runs it.
; Params:
;   bx: start sector
;   cx: sector count
;
[bits 16]
run_chip8_app:
    push bp
    mov bp, sp

    call fill_reserve_bytes

    mov word [chip8_pc], chip8_memory + 0x200
    mov di, [chip8_pc]

    call load_sectors

    mov ax, 0x0013                          ; 320x200 graphics mode 
    int 0x10

    mov ax, 0xa000
    mov es, ax

    mov di, 320 * 100 + 160

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

chip8_memory: times 4096 db 0               ; IMP: allocatin 4kb memory. Please adjust this to accomodate the maximum size of the available ROMs
                                            ; addr where the interpreter starts, first 512 reserved. font data is here
                                            ; app data can be stored at chip8_memory + 512
chip8_pc: dw 0
chip8_stack: times 16 dw 0
chip8_sp: db 0                              ; This is an offset addr into the 'chip8_stack' memory
chip8_V: times 16 db 0
chip8_I: dw 0
chip8_display_buffer: times 32 db 0         ; each bit of the 32 bytes is a pixel, which can be set/unset. each hor. line has 8 bytes, and ver. line has 4 bytes

%endif