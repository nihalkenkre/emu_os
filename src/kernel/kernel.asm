%ifndef KERNEL
%define KERNEL

org 0x7e00
bits 16

start:
	jmp main

msg_hello_kernel: 			db 'Hello World from kernel!'
msg_hello_kernel_len: db ($ - msg_hello_kernel)
msg_bye_kernel:			db 'Bye from Kernel!'
msg_bye_kernel_len: db ($ - msg_bye_kernel)

%include "./src/vbe/setup.asm"

main:
	call setup_vbe

	ret

.halt:
	jmp .halt

%endif