%ifndef KERNEL
%define KERNEL

org 0x8000
bits 16

start:
	jmp main

%include "./src/draw/draw_32.asm"
%include "./src/io/load_apps_from_table_32.asm"
%include "./src/io/load_sectors_32.asm"

;
; ebx: start sector of kernel data
; ecx: number of sectors for kernel data
;

[bits 16]
main:
	mov ax, 0x0013				; set video mode to graphics mode
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
	cli										; disable interrupts

	lgdt [gdt_desc]							; load global descriptor table

	; set the control register value to enter protected mode - currently 16 bit
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax

	; Enable A20 line
	call enable_a20

	jmp CODESEG:start_protected_mode		; jump to 32 bit code, which will be 32 bit protected mode

[bits 16]
enable_a20:
	; disable keyboard
	call a20_wait_input
	mov al, kb_ctrl_disable
	out kb_ctrl_cmd, al

	call a20_wait_input
	mov al, kb_ctrl_read
	out kb_ctrl_cmd, al

	call a20_wait_output
	in al, kb_ctrl_dat
	push eax

	call a20_wait_input
	mov al, kb_ctrl_write
	out kb_ctrl_cmd, al

	; set bit 2 to 1
	call a20_wait_output
	pop eax
	or al, 2
	out kb_ctrl_dat, al

	; enable keyboard
	call a20_wait_input
	mov al, kb_ctrl_enable
	out kb_ctrl_cmd, al

	call a20_wait_input

	ret	

[bits 16]
a20_wait_input:
	in al, kb_ctrl_cmd
	test al, 2
	jnz a20_wait_input
	ret

[bits 16]
a20_wait_output:
	in al, kb_ctrl_cmd
	test al, 1
	jnz a20_wait_output
	ret

[bits 32]
start_protected_mode:
	mov ax, DATASEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	call load_apps_from_table
	mov esi, [0x8404]
	mov ecx, 320 * 200
	call draw_image

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

kb_ctrl_cmd 	equ 0x64
kb_ctrl_dat 	equ 0x60
kb_ctrl_disable equ 0xad
kb_ctrl_enable 	equ 0xae
kb_ctrl_read 	equ 0xd0
kb_ctrl_write 	equ 0xd1

%endif
