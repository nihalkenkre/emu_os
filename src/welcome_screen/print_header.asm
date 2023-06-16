%ifndef PRINT_HEADER
%define PRINT_HEADER

%include "./src/vbe/prints/print_string.asm"

[bits 32]
print_header:
    push ebp
    mov ebp, esp

    mov esi, header
    mov edi, [mode_info_block.phy_base_ptr]
    mov eax, [top_padding_ld]
    mov ebx, [left_padding_ld]

    call print_string_vbe

    mov esp, ebp
    pop ebp

    ret

header:       db '===================', 0x0a, ' Welcome to Emu OS ', 0x0d, '===================', 0x0a, 0

top_padding_ld:  dd 5                          ; Number of chars from top
left_padding_ld: dd 40                         ; Number of chars from left

%endif