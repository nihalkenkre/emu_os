%ifndef PRINT_REG
%define PRINT_REG

%include "./src/prints/print_string.asm"

sample:			db '0123456789ABCDEF'

;
; Params:
;	si		: the label to be printed
;	sp + 4	: the value to be printed
;	cx		: the length of the label
;
[bits 16]
print_reg:
	push bp
	mov bp, sp

	call print_string

	push si
	push bx

	mov si, sp
	add si, 6				; SP offset to get to the required value to be printed 2 for function call 2 for pushed si 2 for pushed bx
	
	mov bx, [si]

	shr bx, 12
	mov ax, [sample + bx]	
	mov ah, 0x0e
	int 10h

	mov bx, [si]
	and bx, 0x0f00
	shr bx, 8
	mov ax, [sample + bx]
	mov ah, 0x0e
	int 10h

	mov bx, [si]
	and bx, 0x00f0
	shr bx, 4
	mov ax, [sample + bx]
	mov ah, 0x0e
	int 10h

	mov bx, [si]
	and bx, 0x000f
	mov ax, [sample + bx]
	mov ah, 0x0e
	int 10h

	pop bx
	pop si

	push sp, bp
	pop bp

	ret

%endif