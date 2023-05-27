%ifndef KERNEL
%define KERNEL

org 0x8000
bits 16

start:
	jmp main

%include "./src/vbe/setup.asm"
%include "./src/prints/print_string.asm"

main:
	mov si, msg_hello_kernel
	mov cl, [msg_hello_kernel_len]
	call print_string

	; call setup_vbe

	; ret

	mov si, msg_bye_kernel
	mov cl, [msg_bye_kernel_len]

	call print_string
	cli
	hlt

.halt:
	jmp .halt

msg_hello_kernel: 			db 'Hello World from kernel!'
msg_hello_kernel_len: db ($ - msg_hello_kernel)
msg_bye_kernel:			db 'Bye from Kernel!'
msg_bye_kernel_len: db ($ - msg_bye_kernel)

%endif