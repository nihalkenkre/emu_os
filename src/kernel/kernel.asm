%ifndef KERNEL
%define KERNEL

org 0x8000
bits 16

start:
	jmp main

%include "./src/prints/print_string.asm"
%include "./src/prints/print_new_line.asm"
%include "./src/draw/draw.asm"
%include "./src/vbe/setup.asm"

[bits 16]
main:
	mov si, msg_hello_kernel
	xor ecx, ecx
	mov cl, [msg_hello_kernel_len]
	call print_string
	call print_new_line

	call setup_vbe
	; call draw_something

	mov si, msg_bye_kernel
	xor ecx, ecx
	mov cl, [msg_bye_kernel_len]
	call print_string
	call print_new_line

	cli

	; lgdt [gdt_desc]

	; mov eax, cr0
	; or eax, 0x1
	; mov cr0, eax

	; jmp CODESEG:start_protected_mode
	
	hlt

.halt:
	jmp .halt

; [bits 32]
; start_protected_mode:
; 	mov ax, DATASEG
; 	mov ds, ax
; 	mov ss, ax
; 	mov es, ax
; 	mov fs, ax
; 	mov gs, ax

; 	; mov edi, [mode_info_block.phy_base_ptr]
; 	; xor eax, eax
; 	; mov ax, word[req_x_res]

; 	; xor ecx, ecx
; 	; mov cx, word[req_y_res]
; 	; mul ecx

; 	; mov ecx, eax
; 	; mov eax, 0x00ff00ff
; 	; rep stosd

; 	hlt

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
	.size:  dw (gdt_end - gdt_start - 1)
	.offset: dd gdt_start

CODESEG equ gdt_start.code - gdt_start
DATASEG equ gdt_start.data - gdt_start

msg_hello_kernel: 			db 'Hello World from kernel!'
msg_hello_kernel_len: db ($ - msg_hello_kernel)
msg_bye_kernel:			db 'Bye from Kernel!'
msg_bye_kernel_len: db ($ - msg_bye_kernel)

%include "./src/vbe/info_blocks.asm"

%endif