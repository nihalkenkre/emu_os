%ifndef PRINTS
%define PRINTS

sample:			db '0123456789ABCDEF'

; To print the value of a register, push the register to the stack and 
; make si point to the stack label
; This prints out the value of SI after printing out the si label
;
; push si
; mov si, si_label where  si_label:	db 'SI:0x', 0
; call print_reg
; pop si
; call print_new_line
;

; Params:
;	si		: the label to be printed
;	sp + 4	: the value to be printed
;
print_reg:
	call puts

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

	ret
;
; Prints a string on the screen
; Params:
;	- ds:si points to string
;	- cx points to length of string
puts:
	push si
	push ax

.loop:
	lodsb				; loads next character into reg al
	
	mov ah, 0x0E		
	mov bh, 0			; page number (text modes)
	int 0x10			; call bios interrupt

	dec cx
	cmp cx, 0
	jnz .loop
	
.done:
	pop ax
	pop si

	ret
;
; Prints a new line to the screen, using int10 commands
;

print_new_line:
	push ax
	mov ah, 0x0e
	mov al, 0xd
	int 0x10

	mov al, 0xa
	int 0x10
	pop ax

	ret	

%endif