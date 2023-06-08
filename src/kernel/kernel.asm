%ifndef KERNEL
%define KERNEL

org 0x8000
bits 16

start:
	jmp main

%include "./src/draw/draw_32.asm"

;
; ebx: start sector of kernel data
; ecx: number of sectors for kernel data
;

[bits 16]
main:
	mov ax, 0x0013				; set graphics mode
	int 0x10

	jmp switch_to_32_bits

.return:

	cli
	hlt

.halt:
	cli
	hlt

[bits 16]
switch_to_32_bits:
	cli

	lgdt [gdt_desc]

	mov eax, cr0
	or eax, 0x1
	mov cr0, eax

	jmp CODESEG:start_protected_mode

[bits 32]
start_protected_mode:
	mov ax, DATASEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	call draw_bands

	hlt

gdt_start:
	.null: 
		dd 0
		dd 0
	.code:
		dw 0xffff
		dw 0
		db 0
		db 0x9a
		db 11001111b
		db 0
	.data:
		dw 0xffff
		dw 0
		db 0
		db 0x92
		db 11001111b
		db 0
gdt_end:

gdt_desc:
	.size:  	dw (gdt_end - gdt_start - 1)
	.offset: 	dd gdt_start

CODESEG equ gdt_start.code - gdt_start
DATASEG equ gdt_start.data - gdt_start

msg_hello_kernel:	db 'Hello World from kernel!', 0
msg_bye_kernel:		db 'Bye from Kernel!', 0

%endif
