org 0x7e00
bits 16

%define ENDL 0x0D, 0x0A

start:
	jmp main
	
print_new_line:
	push ax
	mov ah, 0x0e
	mov al, 0xd
	int 0x10

	mov al, 0xa
	int 0x10
	pop ax

	ret	

; Params:
;	si		: the label to be printed
;	sp + 4	: the value to be printed
;
print_reg:
	call puts

	push si
	push bx

	mov si, sp
	add si, 6				; SP offset to get to the required value to be printed 2 for function call 2 for pushed si 2 for pushed bx
	
	mov bx, [si]

	shr bx, 12
	mov ax, [sample + bx]	
	mov ah, 0x0e
	int 10h

	mov bx, [si]
	and bx, 0x0f00
	shr bx, 8
	mov ax, [sample + bx]
	mov ah, 0x0e
	int 10h

	mov bx, [si]
	and bx, 0x00f0
	shr bx, 4
	mov ax, [sample + bx]
	mov ah, 0x0e
	int 10h

	mov bx, [si]
	and bx, 0x000f
	mov ax, [sample + bx]
	mov ah, 0x0e
	int 10h

	pop bx
	pop si

	ret
;
; Prints a string on the screen
; Params:
;	- ds:si points to string
;
puts:
	push si
	push ax

.loop:
	lodsb				; loads next character into reg al
	or al, al 			; verify if the next character is null
	jz .done
	
	mov ah, 0x0E		
	mov bh, 0			; page number (text modes)
	int 0x10			; call bios interrupt
	
	jmp .loop

.done:
	pop ax
	pop si
	ret

setup_vbe:
	push ax
	push ds
	push di
	push cx
	push dx

	xor ax, ax
	mov es, ax
	mov ax, 0x4f00
	mov di, vbe_info_block
	int 0x10

	cmp al, 0x4f
	jnz .func_not_supported

	cmp ah, 0
	jnz .func_call_failed

	;
	; VbeFarPtr is in segment:offset format, since data is laid out in little endian format
	; the 'MSW' goes to the offset, and the 'LSW' goes to the segment.
	;
	; To print the OEM string we do the following
	push ds
	mov si, word [vbe_info_block.oem_string]
	mov ds, word [vbe_info_block.oem_string + 2]
	call puts
	call print_new_line
	pop ds
	
	push ds
	mov si, word [vbe_info_block.oem_vendor_name_ptr]
	mov ds, word [vbe_info_block.oem_vendor_name_ptr + 2]
	call puts
	call print_new_line
	pop ds

	push ds
	mov si, word [vbe_info_block.oem_product_name_ptr]
	mov ds, word [vbe_info_block.oem_product_name_ptr + 2]
	call puts
	call print_new_line
	pop ds

	push ds
	mov si, word [vbe_info_block.oem_product_rev_ptr]
	mov ds, word [vbe_info_block.oem_product_rev_ptr + 2]
	call puts
	call print_new_line
	pop ds

	; Get supported VBE modes
	mov si, word [vbe_info_block.video_mode_ptr]
	mov ds, word [vbe_info_block.video_mode_ptr + 2]


.video_mode_loop:
	lodsw					; next mode into ax, comes from ds:si

	xor cx, cx
	mov es, cx
	mov di, mode_info_block

	mov cx, ax				; move mode number to cx

	cmp cx, 0xffff			; check if we are at the end of the list
	je .vbe_mode_not_found

	mov ax, 0x4f01			; function to return VBE mode information to es:di
	int 0x10

	cmp al, 0x4f			; Check if function supported
	jne .func_not_supported

	cmp ah, 0
	jne .func_call_failed

	mov dx, [req_x_res]
	cmp dx, [mode_info_block.x_resolution]
	jne .video_mode_loop

	mov dx, [req_y_res]
	cmp dx, [mode_info_block.y_resolution]
	jne .video_mode_loop

	mov dl, [req_bpp]
	cmp dl, [mode_info_block.bits_per_pixel]
	jne .video_mode_loop

.set_vbe_mode:
	; Usable mode is in cx

	mov ax, 0x4f02			; Set VBE mode function
	mov bx, cx				; move mode number to bx

	int 0x10

	jmp .return

.func_not_supported:
	mov si, msg_vbe_func_not_supported
	call puts

.func_call_failed:
	mov si, msg_vbe_func_call_failed
	call puts

.vbe_mode_not_found:
	mov cx, 0
	mov ds, cx
	mov si, msg_vbe_mode_not_found
	call puts

.return:
	pop dx
	pop cx
	pop di
	pop ds
	pop ax

	ret

draw_something:
	push ax
	push ds
	push dx

	mov ah, 0			; Set video mode
	mov al, 0x13		; Set graphical mode
	int 0x10

	mov ah, 0xc			; Change color for a single pixel
	mov al, 0xf			; Pixel color
	mov cx, 200			; Column
	mov dx, 100			; Row
	int 0x10

	pop dx
	pop ds
	pop ax

	ret

main:
	mov si, msg_hello
	call puts
	
	mov si, msg_setup_vbe
	call puts

	; call draw_something

	; call setup_vbe

	mov si, msg_bye
	call puts

	cli
	hlt

.halt:
	jmp .halt

msg_hello: 			db 'Hello World from kernel!', ENDL, 0
msg_setup_vbe: 	db 'setting up vbe...', ENDL, 0
msg_vbe_func_not_supported: db 'VBE function not supported...', ENDL, 0
msg_vbe_func_call_failed: db 'VBE function call failed...', ENDL, 0
msg_vbe_mode_not_found: db 'VBE mode not found...', ENDL, 0
msg_bye:			db 'Bye from Kernel!', ENDL, 0

ax_label: 		db 'AX: 0x', 0
cx_label: 		db 'CX: 0x', 0
dx_label: 		db 'DX: 0x', 0
x_res_label: 	db 'x res:', 0
y_res_label: 	db 'y res:', 0
bpp_label:		db 'bpp:', 0

req_x_res:		dw 0x0280
req_y_res:		dw 0x01e0
req_bpp:		db 0x8

sample:			db '0123456789ABCDEF'

vbe_info_block:
	.signature: 			db 'VESA' 
	.version: 				dw 0x0300 
	.oem_string: 			dd 1
	.capabilities: 			dd 0
	.video_mode_ptr: 		dd 0
	.total_memory: 			dw 0
	.oem_software_rev: 		dw 0
	.oem_vendor_name_ptr:	dd 0
	.oem_product_name_ptr:	dd 0
	.oem_product_rev_ptr:	dd 0
	.reserved:				times 222 db 0
	.oem_data:				times 256 db 0

mode_info_block:

; Information for all VBE revisions
	.mode_attributes:		dw 0
	.win_a_attributes:		db 0
	.win_b_attributes:		db 0
	.win_granularity:		dw 0
	.win_size:				dw 0
	.win_a_segment:			dw 0
	.win_b_segment:			dw 0
	.win_func_ptr:			dd 0
	.bytes_per_scan_line:	dw 0

; Information for VBE 1.2 and above
	.x_resolution:			dw 0
	.y_resolution:			dw 0
	.x_char_size:			db 0
	.y_char_size:			db 0
	.number_of_planes:		db 0
	.bits_per_pixel:		db 0
	.number_of_banks:		db 0
	.memory_model:			db 0
	.bank_size:				db 0
	.number_of_image_pages:	db 0

; Direct Color fields (required for YUV/7 memory models)
	.red_mask_size:			db 0
	.red_field_position:	db 0
	.green_mask_size:		db 0
	.green_field_position:	db 0
	.blue_mask_size:		db 0
	.blue_field_position:	db 0
	.rsvd_mask_size:		db 0
	.direct_color_mode_info:db 0

; Information for VBE 2.0 and above
	.phy_base_ptr:			dd 0
	.reserved_a:			dd 0 ; this is a double word
	.reserved_b:			dw 0 ; this is a word
	
; Information for VBE 3.0 and above
	.lin_bytes_per_scan_line: 	dw 0
	.bnk_num_image_pages:		db 0
	.lin_num_image_pages:		db 0
	.lin_red_mask_size:			db 0
	.lin_red_field_position:	db 0
	.lin_green_mask_size:		db 0
	.lin_green_field_position:	db 0
	.lin_blue_mask_size:		db 0
	.lin_blue_field_position:	db 0
	.lin_rsvd_mask_size:		db 0
	.iln_rsvd_field_position:	db 0
	.max_pixel_clock:			dd 0
	.reserved_c:				times 189 db 0