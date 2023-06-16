%ifndef PRINT_STRING_VBE
%define PRINT_STRING_VBE

%include "./src/vbe/prints/print_char.asm"

;
; Prints a string to the screen
;
; Params:
;   esi: Pointer to the string
;   edi: Pointer to the video memory
;   eax: num chars offset from top
;   ebx: num chars offset from left
;

[bits 32]
print_string_vbe:
    push ebp
    mov ebp, esp
    
    mov [top_padding_st], eax                  ; store the top padding
    mov [left_padding_st], ebx                 ; store the left padding

    ; calculate the padding in bytes for the top padding
    ; bytes_per_scan_line * y_char_size * top_padding_st
    xor eax, eax
    mov ax, [mode_info_block.lin_bytes_per_scan_line]
    xor ebx, ebx
    mov bl, [mode_info_block.y_char_size]
    mul ebx                                 ; eax = bytes_per_scan_line * y_char_size

    mul dword [top_padding_st]                    ; eax * top_padding_st

    mov [top_padding_offset], eax

    ; calculate the padding in bytes for the left padding
    ; x_char_size * left_padding_st

    xor eax, eax
    mov al, [mode_info_block.x_char_size]
    
    mul dword [left_padding_st]                 ; eax = x_char_size * left_padding_st

    mov [left_padding_offset], eax

    add edi, [top_padding_offset]
    add edi, [left_padding_offset]

.loop:
    xor eax, eax
    lodsb
    or al, al
    jz .loop_end
    
    cmp al, 0x0a
    je .new_line

    cmp al, 0x0d
    je .new_line
    
    jmp .print

.new_line:
    ; To write to a new line, we first 
    ;   bytes_per_scan_line * y_char_size, and add this to the current memory location (edi)
    ;
    ; This gives us the memory location of the 'next line', but this is right below the previously written char

    xor eax, eax
    mov ax, [mode_info_block.lin_bytes_per_scan_line]

    xor ebx, ebx
    mov bl, [mode_info_block.y_char_size]

    mul ebx

    add edi, eax                                                ; pointer now at new line, but not at the start

    ; To go to the 'start' of the line, we first
    ; subtract the current memory location from the base memory_location
    ; edi - phy_base_ptr
    ;
    ; and do a bytes_per_scan_line / x_resolution. The remainder is the number of locations from the 'start' of the line
    ;    
    xor edx, edx
    xor eax, eax

    mov eax, edi
    sub eax, [mode_info_block.phy_base_ptr]

    xor ebx, ebx
    mov bx, [mode_info_block.lin_bytes_per_scan_line]
    div ebx                                                     ; quotient is in eax, modulo is in edx

    sub edi, edx                                                ; pointer at the start of the new line
    add edi, [left_padding_offset]                              ; add the left padding offset

    jmp .loop

.print:
    call print_char_vbe

.wrap_text_to_next_line:
    ; First check if edi is at the last byte of the scan line

    ; we subtract edi from the base ptr
    ; edi - phy_base_ptr

    xor edx, edx
    mov eax, edi
    sub eax, [mode_info_block.phy_base_ptr]

    ; then divide by the bytes per scan line
    ; and if the remainder is 0, means we are at the end of the scan line
    xor ebx, ebx
    mov bx, [mode_info_block.lin_bytes_per_scan_line]
    div ebx                                             ; quotient is in eax, remainder in edx

    cmp edx, 0
    jne .loop

    jmp .new_line                                       ; new line if edx is 0

.loop_end:
    ; bring edi to the start of the current line
    ;
    ; To go to the 'start' of the line, we first
    ; subtract the current memory location from the base memory_location
    ; edi - phy_base_ptr
    ;
    ; and do a bytes_per_scan_line / x_resolution. The remainder is the number of locations from the 'start' of the line
    ; 
    xor edx, edx
    xor eax, eax

    mov eax, edi
    sub eax, [mode_info_block.phy_base_ptr]

    xor ebx, ebx
    mov bx, [mode_info_block.lin_bytes_per_scan_line]
    div ebx                                                     ; quotient is in eax, modulo is in edx

    sub edi, edx                                                ; pointer at the start of the new line

    mov esp, ebp
    pop ebp

    ret

test_string: db '=====================', 0x0a, '  Welcome to EMU OS  ', 0x0a, '=====================', 0

top_padding_st:       dd 0                 ; Number of chars from top
left_padding_st:      dd 0                 ; Number of chars from left
top_padding_offset:   dd 0                 ; Total offset in bytes from top padding
left_padding_offset:  dd 0                 ; Total offset in bytes from left padding

alphabet: db ' '
          db '!'
          db '"'
          db '#'
          db '$'
          db '%'
          db '&'
          db 0x27 ; '
          db '('
          db ')'
          db '*'
          db '+'
          db ','
          db '-'
          db '.'
          db '/'
          db '0'
          db '1'
          db '2'
          db '3'
          db '4'
          db '5'
          db '6'
          db '7'
          db '8'
          db '9'
          db ':'
          db ';'
          db '<'
          db '='
          db '>'
          db '?'
          db '@'
          db 'A'
          db 'B'
          db 'C'
          db 'D'
          db 'E'
          db 'F'
          db 'G'
          db 'H'
          db 'I'
          db 'J'
          db 'K'
          db 'L'
          db 'M'
          db 'N'
          db 'O'
          db 'P'
          db 'Q'
          db 'R'
          db 'S'
          db 'T'
          db 'U'
          db 'V'
          db 'W'
          db 'X'
          db 'Y'
          db 'Z'
          db '['
          db '\'
          db ']'
          db '^'
          db '_'
          db '`'
          db 'a'
          db 'b'
          db 'c'
          db 'd'
          db 'e'
          db 'f'
          db 'g'
          db 'h'
          db 'i'
          db 'j'
          db 'k'
          db 'l'
          db 'm'
          db 'n'
          db 'o'
          db 'p'
          db 'q'
          db 'r'
          db 's'
          db 't'
          db 'u'
          db 'v'
          db 'w'
          db 'x'
          db 'y'
          db 'z'
          db '{'
          db '|'
          db '}'
          db '~'
          db 0
%endif