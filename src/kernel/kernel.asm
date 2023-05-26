org 0x7e00
bits 16

start:
	jmp main

main:

	call setup_vbe

	ret

.halt:
	jmp .halt

%include "./src/utils/prints.asm"
%include "./src/vbe/setup.asm"
