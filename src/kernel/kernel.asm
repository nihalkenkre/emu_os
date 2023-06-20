%ifndef KERNEL
%define KERNEL

org 0x8000
bits 16

start:
	jmp main

%include "./src/welcome_screen/welcome_screen.asm"
;
; ebx: start sector of kernel data
; ecx: number of sectors for kernel data
;
[bits 16]
main:
	mov ax, 0x0003
	int 0x10

	call print_welcome_screen

	; mov si, msg_bye_kernel
	; call print_string
	; call print_new_line

	; call clear_screen

	; xor dx, dx
	; mov dx, 0x041d
	; mov ah, 0x2
	; int 0x10

	; mov al, 'A'
	; mov ah, 0x9
	; mov bl, 0x1f
	; mov cx, 1
	; int 0x10

	hlt	

msg_hello_kernel:	db 'Hello World from kernel!', 0
msg_bye_kernel:		db 'Bye from Kernel!', 0

%endif
