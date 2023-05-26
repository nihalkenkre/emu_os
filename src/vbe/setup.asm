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
	;
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
	mov bx, cx				; move mode number to bx for int 10
	or bx, 0x4000			; Enable linear frame buffer mode

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

.mode_not_available:
	mov si, msg_vbe_mode_not_available
	call puts

	pop cx
	pop di
	pop es
	pop eax
	
	ret

req_x_res:		dw 0x0780
req_y_res:		dw 0x0438
req_bpp:		db 0x8

%include "./src/vbe/info_blocks.asm"