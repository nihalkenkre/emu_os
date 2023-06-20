%ifndef PRINT_CHAR_VBE
%define PRINT_CHAR_VBE

%include "./src/fonts/fonts.asm"

;
; Prints a character from the bitmap font to the screen
;
; Params:
;   eax - ascii code of the character
;   edi - pointer to the linear buffer
;
[bits 32]
print_char_vbe:
    push ebp
    mov ebp, esp

    push esi

    shl eax, 4

    mov esi, fonts                              ; pointer to font glyphs
    add esi, eax                                ; offset to the ascii value in the fonts 'array' to 
                                                ; get the required glyph for the char.

    xor edx, edx                                ; edx is used in some operations, and may contain 
                                                ; undesired values

.loop_y:                                        ; loop for the height of the glyph
    xor ecx, ecx
    mov cl, [mode_info_block.x_char_size]

.loop_x:                                        ; loop for the width of the glyph
    bt word [esi], cx                           ; check if bit is set in the byte
    jc .foreground
    jnc .background

.foreground:
    mov byte [edi], 0x7
    inc edi

    jmp .continue

.background:
    cmp byte [is_selected], 0
    je .not_selected

.selected:
    mov byte [edi], 0x4
    inc edi
    jmp .continue

.not_selected:
    mov byte [edi], 0x1
    inc edi
    jmp .continue

.continue:
    dec cl
    jnz .loop_x
    
    ; now edi is pointing to the right of the char printed
    ; We have to bring to the left of the next line

    ; So first
    ; edi + bytes_per_scan_line, will bring edi to the right of next line of the char
    add edi, [mode_info_block.lin_bytes_per_scan_line]

    ; and then 
    ; edi - x_char_size, will bring edi to the left of next line of the char
    xor ebx, ebx
    mov bl, [mode_info_block.x_char_size]
    sub edi, ebx                                    

    inc esi                                     ; point to the next line(byte) in the char glyph

    inc dl
    cmp dl, [mode_info_block.y_char_size]
    jnz .loop_y                                 ; one char has been printed

    ; edi is now pointing to the bottom right of the char
    ;
    ; To print the next char it has to be taken to the top right of the current char,
    ; which is the top left of the next char

    ; So we first get the number of bytes to go to the top of the char
    ; bytes_per_scan_line * y_char_size
    xor ebx, ebx
    xor eax, eax
    mov ebx, [mode_info_block.lin_bytes_per_scan_line]
    mov al, [mode_info_block.y_char_size]
    mul ebx                                             ; result is stored in eax

    ; and subtract it from edi
    ; edi - (bytes_per_scan_line * y_char_size)
    sub edi, eax                                        ; edi is on top left of the char

    ; To go to the top right of the char we add the x_char_size to edi
    xor ebx, ebx
    mov bl, [mode_info_block.x_char_size]
    add edi, ebx

.return:
    pop esi

    mov esp, ebp
    pop ebp

    ret

is_selected: db 0

%endif