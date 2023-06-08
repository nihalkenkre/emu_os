%ifndef SETUP_DATA
%define SETUP_DATA

req_x_res:		dw 0x0280
req_y_res:		dw 0x01e0
req_bpp:		db 0x2

msg_vbe_setup: 	db 'setting up vbe...', 0
msg_vbe_func_not_supported: db 'VBE function not supported...', 0
msg_vbe_func_call_failed: db 'VBE function call failed...', 0
msg_vbe_mode_not_found: db 'VBE mode not found...', 0
msg_vbe_mode_not_available: db 'VBE mode not available...', 0

%endif