%ifndef VBE_SETUP
%define VBE_SETUP

%include "./src/prints/print_new_line.asm"

[bits 16]
setup_vbe:
	pusha

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
	;
	push ds
	mov si, word [vbe_info_block.oem_string]
	mov ds, word [vbe_info_block.oem_string + 2]
	mov ecx, -1
	call print_string
	call print_new_line
	pop ds
	 
	
	push ds
	mov si, word [vbe_info_block.oem_vendor_name_ptr]
	mov ds, word [vbe_info_block.oem_vendor_name_ptr + 2]
	mov ecx, -1
	call print_string
	call print_new_line
	pop ds

	push ds
	mov si, word [vbe_info_block.oem_product_name_ptr]
	mov ds, word [vbe_info_block.oem_product_name_ptr + 2]
	mov ecx, -1
	call print_string
	call print_new_line
	pop ds

	push ds
	mov si, word [vbe_info_block.oem_product_rev_ptr]
	mov ds, word [vbe_info_block.oem_product_rev_ptr + 2]
	mov ecx, -1
	call print_string
	call print_new_line
	pop ds

	; Get supported VBE modes
	mov si, word [vbe_info_block.video_mode_ptr]
	mov ds, word [vbe_info_block.video_mode_ptr + 2]


.video_mode_loop:
	lodsw					; next mode into ax, comes from ds:si

	mov cx, ax				; move mode number to cx

	cmp cx, 0xffff			; check if we are at the end of the list
	je .vbe_mode_not_found

	push cx
	xor cx, cx
	mov es, cx
	pop cx

	mov di, mode_info_block

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
	mov bx, cx				; move mode number to bx for int 10
	or bx, 0x4000			; Enable linear frame buffer mode

	int 0x10

	jmp .return

.func_not_supported:
	mov si, msg_vbe_func_not_supported
	xor ecx, ecx
	mov cl, [msg_vbe_func_not_supported_len]
	call print_string
	jmp .return

.func_call_failed:
	mov si, msg_vbe_func_call_failed
	xor ecx, ecx
	mov cl, [msg_vbe_func_call_failed_len]
	call print_string
	jmp .return

.vbe_mode_not_found:
	mov si, msg_vbe_mode_not_found
	xor ecx, ecx
	mov cl, [msg_vbe_mode_not_found_len]
	call print_string
	jmp .return

.mode_not_available:
	mov si, msg_vbe_mode_not_available
	xor ecx, ecx
	mov cl, [msg_vbe_mode_not_available_len]
	call print_string
	jmp .return

.return:
	popa

	ret


req_x_res:		dw 0x0280
req_y_res:		dw 0x01e0
req_bpp:		db 0x245

msg_vbe_setup: 	db 'setting up vbe...'
msg_vbe_setup_len: db ($ - msg_vbe_setup)
msg_vbe_func_not_supported: db 'VBE function not supported...'
msg_vbe_func_not_supported_len: db ($ - msg_vbe_func_not_supported)
msg_vbe_func_call_failed: db 'VBE function call failed...'
msg_vbe_func_call_failed_len: db ($ - msg_vbe_func_call_failed)
msg_vbe_mode_not_found: db 'VBE mode not found...'
msg_vbe_mode_not_found_len: db ($ - msg_vbe_mode_not_found)
msg_vbe_mode_not_available: db 'VBE mode not available...'
msg_vbe_mode_not_available_len: db ($ - msg_vbe_mode_not_available)

%include "./src/vbe/info_blocks.asm"

%endif