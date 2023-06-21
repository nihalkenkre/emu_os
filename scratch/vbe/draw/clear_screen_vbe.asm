%ifdef VBE
%ifndef CLEAR_SCREEN_VBE
%define CLEAR_SCREEN_VBE

[bits 32]
clear_screen_vbe:
    push ebp
    mov ebp, esp

    mov edi, [mode_info_block.phy_base_ptr]
    mov ecx, 640 * 480
    mov eax, 0x1

    rep stosb

    mov esp, ebp
    pop ebp

    ret

%endif
%endif