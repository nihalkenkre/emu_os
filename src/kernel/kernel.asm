%ifndef KERNEL
%define KERNEL

org 0x7e00
bits 16

start:
	jmp main

%include "./src/vbe/setup.asm"

main:
	call setup_vbe

	ret

.halt:
	jmp .halt

%endif