%ifndef DRAW
%define DRAW

[bits 16]
draw_something:
	push bp
	mov bp, sp

	pusha

	mov ah, 0			; Set video mode
	mov al, 0x13		; Set graphical mode
	int 0x10

	mov ax, 0xa000
	mov es, ax
	mov di, 0x0000
	
	mov cx, 160 * 100
	mov al, 0xaa
	rep stosb

	mov cx, 160 * 100
	mov al, 0x01
	rep stosb

	mov cx, 160 * 100
	mov al, 0x05
	rep stosb

	mov cx, 160 * 100
	mov al, 0x04
	rep stosb

	popa

	mov sp, bp
	pop bp

	ret

%endif