%ifndef DRAW
%define DRAW

[bits 16]
draw_bands:
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
	mov al, 0xfc
	rep stosb

	mov cx, 160 * 100
	mov al, 0x03
	rep stosb

	mov cx, 160 * 100
	mov al, 0x02
	rep stosb

	mov cx, 160 * 100
	mov al, 0xe0
	rep stosb

	popa

	mov sp, bp
	pop bp

	ret

[bits 16]
draw_image:
	push bp
	mov bp, sp

	pusha

	mov ah, 0
	mov al, 0x13
	int 0x10

	mov ax, 0xa000
	mov es, ax
	mov di, 0x0000

	popa

	mov sp, bp
	pop bp

	ret

%endif