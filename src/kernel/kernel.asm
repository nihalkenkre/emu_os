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

	call load_apps_from_table

	; 0x8200 - the number of apps 
	; 0x8202::0x83ff -  the 16 bits locations of the app data
	
	cmp word [0x8200], 0				; check if number of apps are zero
	je .return

	mov cx, word [0x8200]				; cx - number of apps

	mov si, word [0x8202]
	mov ax, 0xa000
	mov es, ax
	mov di, 0x0000

	mov ax, 0x0013
	int 0x10

	push cx
	mov cx, 320 * 200
	rep movsb
	
	pop cx								; get back number of apps

	jmp .halt

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

%endif