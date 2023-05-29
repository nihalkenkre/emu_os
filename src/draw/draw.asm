%ifndef DRAW
%define DRAW

[bits 16]
draw_something:
	pusha

	mov ah, 0			; Set video mode
	mov al, 0x13		; Set graphical mode
	int 0x10

	; mov ah, 0xc			; Change color for a single pixel
	; mov al, 0xf			; Pixel color
	; mov cx, 200			; Column
	; mov dx, 100			; Row
	; int 0x10

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

	ret

%endif