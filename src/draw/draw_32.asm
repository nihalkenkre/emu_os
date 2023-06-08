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


%endif