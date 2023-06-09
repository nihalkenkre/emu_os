org 0x7C00
bits 16

start:
    jmp main

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
;
puts:
	push si
	push ax

.loop:
	lodsb				; loads next character into reg al
	or al, al 			; verify if the next character is null
	jz .done
	
	mov ah, 0x0E		
	mov bh, 0			; page number (text modes)
	int 0x10			; call bios interrupt
	
	jmp .loop

.done:
	pop ax
	pop si

	ret

main:
    
	mov ax, 0xDEAD
	push ax
	mov si, ax_label
	call print_reg
	pop ax

    cli
    hlt

ax_label: 	db 'AX: 0x', 0
sample:		db '0123456789ABCDEF'

times 510-($-$$) db 0
dw 0xAA55