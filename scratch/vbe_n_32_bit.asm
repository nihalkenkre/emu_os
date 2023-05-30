; Extracted from the erstwhile kernel.asm
;
.setup_vbe:
	call setup_vbe
	
	cmp ax, 0
	jne .vbe_setup_failed
	jmp switch_to_32_bits

.vbe_setup_failed:
	cmp ax, 1
	je .vbe_function_not_supported
	cmp ax, 2
	je .vbe_function_call_failed
	cmp ax, 3
	je .vbe_mode_not_found
	cmp ax, 4
	je .vbe_mode_not_available

.vbe_function_not_supported:
	mov si, msg_vbe_func_not_supported
	xor ax, ax
	mov ds, ax
	call print_string
	call print_new_line
	jmp .return

.vbe_function_call_failed:
	mov si, msg_vbe_func_call_failed
	xor ax, ax
	mov ds, ax
	call print_string
	call print_new_line
	jmp .return

.vbe_mode_not_found:
	mov si, msg_vbe_mode_not_found
	xor ax, ax
	mov ds, ax
	call print_string
	call print_new_line
	jmp .return

.vbe_mode_not_available:
	mov si, msg_vbe_mode_not_available
	xor ax, ax
	mov ds, ax
	call print_string
	call print_new_line
	jmp .return


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

	mov edi, [mode_info_block.phy_base_ptr]
	mov eax, 0xff00ffff
	mov ecx, 640 * 480

	rep stosd

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
