%ifndef DRAW_VBE
%define DRAW_VBE

;
; Copy the contents of esi to edi
;
;
[bits 32]
draw_vbe:
    push ebp
    mov ebp, esp

    mov edi, [mode_info_block.phy_base_ptr]
    mov eax, 0x01
    mov ecx, 640 * 480

    rep stosb

    mov esp, ebp
    pop ebp
    
    ret

%endif