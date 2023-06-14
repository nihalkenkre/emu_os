%ifndef PRINT_CHAR_VBE
%define PRINT_CHAR_VBE

%include "./src/fonts/fonts.asm"

;
; Prints a character from the bitmap font to the screen
;
; Params:
;   eax - ascii code of the character
;   esi - pointer to the string
;   edi - pointer to the linear buffer
;
[bits 32]
print_char_vbe:
    push ebp
    mov ebp, esp

    push esi

    shl eax, 4

    mov esi, fonts
    add esi, eax

    xor edx, edx

.loop_y:
    xor ecx, ecx
    mov cl, [mode_info_block.x_char_size]

.loop_x:
    bt word [esi], cx
    jc .foreground
    jnc .background

.foreground:
    mov byte [edi], 0x7
    inc edi

    jmp .continue

.background:
    mov byte [edi], 0x1
    inc edi

    jmp .continue

.continue:
    dec cl
    jnz .loop_x
    
    add edi, [mode_info_block.lin_bytes_per_scan_line]
    xor ebx, ebx
    mov bl, [mode_info_block.x_char_size]
    sub edi, ebx

    inc esi

    inc dl
    cmp dl, [mode_info_block.y_char_size]
    jnz .loop_y

    xor ebx, ebx
    xor eax, eax
    mov ebx, [mode_info_block.lin_bytes_per_scan_line]
    mov al, [mode_info_block.y_char_size]
    mul ebx

    sub edi, eax

    xor ebx, ebx
    mov bl, [mode_info_block.x_char_size]
    add edi, ebx

.return:
    pop esi

    mov esp, ebp
    pop ebp

    ret


%endif