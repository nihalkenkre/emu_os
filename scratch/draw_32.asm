%ifndef DRAW_32
%define DRAW_32


[bits 32]
draw_bands:
    push ebp
    mov ebp, esp

    pusha

	mov edi, 0xa0000

	mov cx, 160 * 100
	mov al, 0x01
	rep stosb

	mov cx, 160 * 100
	mov al, 0x05
	rep stosb

	mov cx, 160 * 100
	mov al, 0x02
	rep stosb

	mov cx, 160 * 100
	mov al, 0x4
	rep stosb

    popa

    mov esp, ebp
    pop ebp

    ret

;
; Displays the data at the memory locations starting at si to video memory starting at 0xa0000
;
; Params:
;	esi: starting mem locations
;	ecx: number of pixels / bytes to copy
;
[bits 32]
draw_image:
	push ebp
	mov ebp, esp

	push edi
	mov edi, 0xa0000

	rep movsb

	pop edi

	mov esp, ebp
	pop ebp

	ret

%endif