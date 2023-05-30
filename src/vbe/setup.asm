%ifndef VBE_SETUP
%define VBE_SETUP

;
; Setup VESA BIOS Extension for 640 x 480, 32 bpp
;
; Returns:
;	ax: 0 		VBE mode successfully set
;		1		VBE function not supported
;		2		VBE function not called
;		3		VBE mode not found
;		4		VBE mode not available
;
setup_vbe:
	; push bp
	; mov bp, sp

	pusha

	mov ax, 0x4f00
	mov di, vbe_info_block
	int 0x10

	cmp al, 0x4f
	jne .func_not_supported

	cmp ah, 0
	jne .func_call_failed

	;
	; VbeFarPtr is in segment:offset format, since data is laid out in little endian format
	; the 'MSW' goes to the offset, and the 'LSW' goes to the segment.
	;
	push ds
	mov si, word [vbe_info_block.oem_string]
	mov ds, word [vbe_info_block.oem_string + 2]
	call print_string
	call print_new_line
	pop ds
	
	push ds
	mov si, word [vbe_info_block.oem_vendor_name_ptr]
	mov ds, word [vbe_info_block.oem_vendor_name_ptr + 2]
	call print_string
	call print_new_line
	pop ds

	push ds
	mov si, word [vbe_info_block.oem_product_name_ptr]
	mov ds, word [vbe_info_block.oem_product_name_ptr + 2]
	call print_string
	call print_new_line
	pop ds

	push ds
	mov si, word [vbe_info_block.oem_product_rev_ptr]
	mov ds, word [vbe_info_block.oem_product_rev_ptr + 2]
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

	ret

.func_not_supported:
	popa
	mov ax, 0x1

	ret

.func_call_failed:
	popa
	mov ax, 0x2

	ret

.vbe_mode_not_found:
	popa
	mov ax, 0x3

	ret

.mode_not_available:
	popa
	mov ax, 0x4

	ret

.return:
	popa
	xor ax, ax

	; mov sp, bp
	; pop bp

	ret

%endif