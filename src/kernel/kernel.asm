%ifndef KERNEL
%define KERNEL

org 0x8000
bits 16

start:
	jmp main

%include "./src/draw/draw.asm"
%include "./src/prints/print_string.asm"
%include "./src/prints/print_new_line.asm"
%include "./src/io/load_apps_from_table.asm"

;
; ebx: start sector of kernel data
; ecx: number of sectors for kernel data
;
[bits 16]
main:
	mov si, msg_hello_kernel
	call print_string
	call print_new_line

.return:
	mov si, msg_bye_kernel
	call print_string
	call print_new_line

	hlt

.halt:
	jmp .halt

msg_hello_kernel: 		db 'Hello World from kernel!', 0
msg_bye_kernel:			db 'Bye from Kernel!', 0

%endif