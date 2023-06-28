%ifndef RUN_CHIP8
%define RUN_CHIP8


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
; Fill the screen with constant color
;
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
; 'Blit' the display buffer to the screen
;
[bits 16]
update_screen:
    push bp
    mov bp, sp

    push ax
    push es
    push si
    push di

    mov ax, 0xa000
    mov es, ax

    mov si, chip8_display_buffer
    mov di, 320 * 21

    ;; For each byte in the display buffer
    ;; the vga buffer is filled with 5x5 byte square
    mov cx, 32
    .blit:
        push cx
        mov cx, 64

        .line:
            lodsb                      ; al contains the display buffer byte
            push cx

            mov bx, 5                  ; vertical side
            .pixel:
                mov cx, 5              ; horizontal line
                rep stosb
            
                add di, 320
                sub di, 5

                dec bx
                jnz .pixel

            sub di, 320 * 5
            add di, 5

            pop cx
            dec cx

            jnz .line

        add di, 320 * 5
        sub di, 320

        pop cx
        dec cx
        jnz .blit

    pop di
    pop si
    pop es
    pop ax

    mov sp, bp
    pop bp

    ret

;
; Fetches the next 2 byte opcode from the 'chip8' memory and executes it
; Chip8 is Big Endian and x86 is Little Endian
; So the higher bytes of the opcode are stored as the lower bytes in the memory addr
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

    cmp ah, 7
    je .first_7

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

        xor bx, bx
        and ah, 0x0f
        mov bl, ah

        mov [chip8_V + bx], al
        add word [chip8_pc], 2

        jmp .return

    .first_7:
        pop ax

        and ah, 0x0f
        xor bx, bx
        mov bl, ah

        xor dx, dx
        mov dl, [chip8_V + bx]
        add dl, al

        mov [chip8_V + bx], dl

        add word [chip8_pc], 2

        jmp .return

    .first_a:
        pop ax                              ; retrieve the full opcode

        and ax, 0x0fff
        mov [chip8_I], ax

        add word [chip8_pc], 2

        jmp .return

    .first_c:
        pop ax                              ; retrieve the full opcode
        

        add word [chip8_pc], 2
        
        jmp .return

    .first_d:
        pop ax                              ; retrieve the full opcode
    
        and ax, 0x0fff                      ; *XYN

        push ax                             ; save xyn so we can extract x y n
        and al, 0x0f
        xor cx, cx
        mov cl, al                          ; cl contains nn
        mov byte [opcode_nn], cl
        pop ax

        push ax                             ; save xyn so we can extract x y n
        and al, 0xf0
        shr al, 4
        xor bx, bx
        mov bl, al                          ; bl contains y
        mov byte [opcode_yy], bl
        pop ax

        push ax                             ; save xyn so we can extract x y n
        and ah, 0x0f
        xor dx, dx
        mov dl, ah                          ; dl contains x
        mov byte [opcode_xx], dl
        pop ax

        ; Get the y co-ordinate
        mov si, chip8_V
        add si, bx
        mov di, current_y
        movsb

        and byte [current_y], 31

        ; Get the x co-ordinate
        mov si, chip8_V
        add si, dx
        mov di, current_x
        movsb

        and byte [current_x], 63
    
        mov al, 64
        mul byte [current_y]
        add al, [current_x]                              ; ax = y * 64 + x

        mov [current_display_buffer_offset], ax
        mov byte [chip8_V + 0xf], 0

        mov ch, 0                               ; this will be the index of the counter, going to cl(nn)

        .n_loop:
            ; Get the Nth row byte into ax
            ; row = chip8_memory[chip8_I + n]
        
            ; First calculate the chip_I + n
            mov ax, [chip8_I]

            push cx
            xchg ch, cl                         ; to get the current n into cl
            xor ch, ch
            add ax, cx                          ; ax containx chip8_I + n
            pop cx

            ; move the byte from memory offset by ax into chip8_memory to nth_row_byte
            mov si, chip8_memory
            add si, ax
            mov di, nth_row_byte
            movsb

            xor bx, bx
            mov bx, [current_display_buffer_offset]

            push cx
            xor cx, cx
            mov cl, 8
        
            .bits_loop:
                dec cl
            
                mov al, [chip8_display_buffer + bx]
                cmp al, background_color

                je .display_pixel_is_bg
                jne .display_pixel_is_fg

                .display_pixel_is_bg:
                    mov al, [nth_row_byte]
                    bt ax, cx

                    jnc .bits_loop_continue

                    mov byte [chip8_display_buffer + bx], foreground_color

                    jmp .bits_loop_continue

                .display_pixel_is_fg:
                    mov al, [nth_row_byte]
                    bt ax, cx

                    jnc .bits_loop_continue

                    mov byte [chip8_display_buffer + bx], background_color
                    mov byte [chip8_V + 0xf], 1

                .bits_loop_continue:

                inc word bx                                 ; go to next pixel; equ x++

                cmp cl, 0
                jne .bits_loop

            pop cx

            add bx, 64                                      ; go to next scan line; equ y++
            sub bx, 8

            mov [current_display_buffer_offset], bx

            inc byte ch
            cmp ch, cl
            jne .n_loop

        add word [chip8_pc], 2

        call update_screen

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
; Test the display buffer to screen mapping
;
[bits 16]
test_display_buffer:
    push bp
    mov bp, sp

    push es

    xor ax, ax
    mov es, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx

    ; Fill a double line with the foreground color, top padding of 2

    mov di, chip8_display_buffer
    add di, 128
    mov al, foreground_color
    mov cl, 128

    rep stosb

    ; Update the vga memory
    mov ax, 0xa000
    mov es, ax

    mov si, chip8_display_buffer
    mov di, 320 * 21

    ;; For each byte in the display buffer
    ;; the vga buffer is filled with 5x5 byte square
    mov cx, 32
    .blit:
        push cx
        mov cx, 64

        .line:
            lodsb                      ; al contains the display buffer byte
            push cx

            mov bx, 5                  ; vertical side
            .pixel:
                mov cx, 5              ; horizontal line
                rep stosb
            
                add di, 320
                sub di, 5

                dec bx
                jnz .pixel

            sub di, 320 * 5
            add di, 5

            pop cx
            dec cx

            jnz .line

        add di, 320 * 5
        sub di, 320

        pop cx
        dec cx
        jnz .blit

    pop es

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

    push es

    call fill_reserve_bytes

    mov word [chip8_pc], chip8_memory + 0x200
    mov di, [chip8_pc]

    call load_sectors

    mov ax, 0x0013                          ; 320x200 graphics mode 
    int 0x10

.timer_loop:
    ; mov ah, 0
    ; int 0x1a
    
    ; add dx, 0x7f
    ; mov bx, dx

    mov ecx, 0xfffff

    ; mov cx, [0x046c]
    ; add cx, 0xf

.timer_wait:
    ; mov ah, 0
    ; int 0x1a

    ; cmp dx, bx
    dec ecx

    ; mov bx, [0x046c]
    ; cmp cx, [0x046c]
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

    pop es
    
    ;; clear out display buffer
    mov cx, 64 * 32
    mov ax, background_color
    mov di, chip8_display_buffer
    rep stosb

    ;; clear out chip8_memory
    mov cx, 4096
    mov ax, 0
    mov di, chip8_memory
    rep stosb

    mov sp, bp
    pop bp

    jmp print_welcome_screen

    ret

background_color equ 0x6b
foreground_color equ 0x1f

esc_scan_code equ 0x01

sector_size equ 512

chip8_pc: dw 0
chip8_stack: times 16 dw 0
chip8_sp: db 0                              ; This is an offset addr into the 'chip8_stack' memory
chip8_V: times 16 db 0
chip8_I: dw 0
chip8_display_buffer: times 64 * 32 db background_color    ; background: 0x6b, foreground: 0x1f

nth_row_byte: db 0
display_byte: db 0
opcode_xx: db 0
opcode_yy: db 0
opcode_nn: db 0
current_n: db 0
current_x: db 0
current_y: db 0
current_display_buffer_offset: dw 0
chip8_memory: times 4096 db 0               ; IMP: allocatin 4kb memory. Please adjust this to accomodate the maximum size of the available ROMs
                                            ; addr where the interpreter starts, first 512 reserved. font data is here
                                            ; app data can be stored at chip8_memory + 512

%endif