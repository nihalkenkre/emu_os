%ifndef PRINT_HEADER
%define PRINT_HEADER

%include "./src/vbe/prints/print_string.asm"

[bits 32]
print_header:
    push ebp
    mov ebp, esp

    mov edi, [mode_info_block.phy_base_ptr]

    mov esi, header
    mov dword [top_padding], 1
    mov dword [left_padding], 28
    call print_string_vbe

    mov esp, ebp
    pop ebp

    ret

header:       db '===================', 0x0a, ' Welcome to Emu OS ', 0x0d, '===================', 0x0a, 0

; top_padding_ld:  dd 1                          ; Number of chars from top
; left_padding_ld: dd 28                        ; Number of chars from left

%endif