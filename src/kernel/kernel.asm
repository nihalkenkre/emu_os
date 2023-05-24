org 0x7e00
bits 16

%define ENDL 0x0D, 0x0A


start:
	jmp main

draw_something:
	push ax
	push ds
	push dx
	push es
	push di
	push cx

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

	push cx
	pop di
	pop es
	pop dx
	pop ds
	pop ax

	ret

main:
	call draw_something

	ret

.halt:
	jmp .halt

%include "./src/utils/prints.asm"