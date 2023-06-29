%ifndef KERNEL
%define KERNEL

org 0x8000
bits 16

start:
	jmp main

%include "./src/welcome_screen/welcome_screen.asm"
;
; bx: start sector of kernel data
; cx: number of sectors for kernel data
;
[bits 16]
main:
	mov ax, 0x0003
	int 0x10

	mov [kernel_data_start_sec], bx
	mov [kernel_data_sec_count], cx

	jmp print_welcome_screen

	hlt	

msg_hello_kernel:	db 'Hello World from kernel!', 0
msg_bye_kernel:		db 'Bye from Kernel!', 0

kernel_data_start_sec: dw 0
kernel_data_sec_count: dw 0

%endif
