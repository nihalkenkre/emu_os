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

	hlt

;
; ebx: start sector of kernel data
; ecx: number of sectors for kernel data
;
[bits 16]
main:
	mov si, msg_hello_kernel
	call print_string
	call print_new_line

	jmp switch_to_32_bits

	; call load_apps_from_table

	; 0x8200 - the number of apps 
	; 0x8202::0x83ff -  the 16 bits locations of the app data
	
	; cmp word [0x8200], 0				; check if number of apps are zero
	; je .return

	; mov cx, word [0x8200]				; cx - number of apps

	; mov si, word [0x8202]
	; mov ax, 0xa000
	; mov es, ax
	; mov di, 0x0000

	; mov ax, 0x0013
	; int 0x10

	; push cx
	; mov cx, 320 * 200
	; rep movsb
	
	; pop cx								; get back number of apps

	; jmp .halt

.return:
	mov si, msg_bye_kernel

	call print_string
	call print_new_line

	cli
	hlt

.halt:
	cli
	hlt

msg_hello_kernel:	db 'Hello World from kernel!', 0
msg_bye_kernel:		db 'Bye from Kernel!', 0
<<<<<<< HEAD

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
=======
>>>>>>> 709cccef0bbbf07f9bc0318c97203318987fb8d0

%endif