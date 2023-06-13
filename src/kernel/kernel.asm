%ifndef KERNEL
%define KERNEL

org 0x8000
bits 16

start:
	jmp main

%include "./src/io/load_apps_from_table_32.asm"
%include "./src/vbe/setup.asm"
%include "./src/vbe/draw/draw_vbe.asm"
%include "./src/vbe/prints/print_string.asm"
;
; ebx: start sector of kernel data
; ecx: number of sectors for kernel data
;

[bits 16]
main:
	mov si, msg_hello_kernel
	call print_string
	call print_new_line

	call setup_vbe
	cmp al, 0
	jne .vbe_error

	jmp switch_to_32_bits

.vbe_error:
	cmp al, 1
	je .vbe_func_not_supported

	cmp al, 2
	je .vbe_func_call_failed

	cmp al, 3
	je .vbe_mode_not_found

	cmp al, 4
	je .vbe_mode_not_available

	jmp .return

.vbe_func_not_supported:
	mov si, msg_vbe_func_not_supported
	jmp .print_error_string

.vbe_func_call_failed:
	mov si, msg_vbe_func_call_failed
	jmp .print_error_string

.vbe_mode_not_found:
	mov si, msg_vbe_mode_not_found
	jmp .print_error_string

.vbe_mode_not_available:
	mov si, msg_vbe_mode_not_available
	jmp .print_error_string

.print_error_string:
	call print_string
	call print_new_line

.return:
	mov si, msg_bye_kernel
	call print_string
	call print_new_line

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

	jmp CODESEG:start_protected_mode		; jump to 32 bit code, which will be 32 bit protected mode

[bits 32]
start_protected_mode:
	mov ax, DATASEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	; call draw_vbe
	call print_string_vbe

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
