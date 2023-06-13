%ifndef PRINT_STRING_VBE
%define PRINT_STRING_VBE

%include "./src/vbe/prints/print_char.asm"

[bits 32]
print_string_vbe:
    push ebp
    mov ebp, esp

    mov esi, alphabet
    mov edi, [mode_info_block.phy_base_ptr]

.loop:
    xor eax, eax
    lodsb
    or al, al

    jz .loop_end
    call print_char_vbe

    jmp .loop

.loop_end
    mov esp, ebp
    pop ebp

    ret

test_string: db 'DEAD BABE', 0

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
          db 0
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