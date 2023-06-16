%ifndef PRINT_NEW_LINE_VBE
%define PRINT_NEW_LINE_VBE

[bits 32]
print_new_line_vbe:
    push ebp
    mov ebp, esp

    push esi

    mov esi, new_line

    call print_string_vbe

    pop esi

    mov esp, ebp
    pop ebp

    ret

new_line: db 0x0a

%endif