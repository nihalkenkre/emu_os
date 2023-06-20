%ifndef KERNEL
%define KERNEL

org 0x8000
bits 16

start:
	jmp main

%include "./src/prints/print_string.asm"
%include "./src/prints/print_new_line.asm"
%include "./src/draw/draw_16.asm"
%include "./src/prints/clear_screen.asm"
;
; ebx: start sector of kernel data
; ecx: number of sectors for kernel data
;
[bits 16]
main:
	mov ax, 0x0003
	int 0x10

	call clear_screen

	mov ah, 00
	int 0x16

	; mov si, msg_hello_kernel
	; call print_string
	; call print_new_line

	; mov si, msg_bye_kernel
	; call print_string
	; call print_new_line

	; xor dx, dx
	; mov dl, 0
	; mov dh, 10

	; xor ax, ax
	; mov al, 'a'
	; mov ah, 0x2
	; int 0x10

	; mov ah, 0x9
	; mov bl, 0x1f
	; int 0x10
	
	hlt	

msg_hello_kernel:	db 'Hello World from kernel!', 0
msg_bye_kernel:		db 'Bye from Kernel!', 0

%endif
