%ifndef INFO BLOCKS
%define INFO_BLOCKS

vbe_info_block:
	.signature: 			db 'VESA' 
	.version: 				dw 0
	.oem_string: 			dd 0
	.capabilities: 			times 4 db 0
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
	.reserved:				db 0

; Direct Color fields (required for YUV/7 memory models)
	.red_mask_size:			db 0
	.red_field_position:	db 0
	.green_mask_size:		db 0
	.green_field_position:	db 0
	.blue_mask_size:		db 0
	.blue_field_position:	db 0
	.rsvd_mask_size:		db 0
	.rsvd_field_position:	db 0
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

%endif