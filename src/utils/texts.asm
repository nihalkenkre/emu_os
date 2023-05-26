%ifndef TEXTS
%define TEXTS

%define ENDL 0x0D, 0x0A

msg_hello: 			db 'Hello World!', ENDL, 0
msg_hello_kernel: 			db 'Hello World from kernel!', ENDL, 0
msg_setup_vbe: 	db 'setting up vbe...', ENDL, 0
msg_vbe_func_not_supported: db 'VBE function not supported...', ENDL, 0
msg_vbe_func_call_failed: db 'VBE function call failed...', ENDL, 0
msg_vbe_mode_not_found: db 'VBE mode not found...', ENDL, 0
msg_vbe_mode_not_available: db 'VBE mode not available...', ENDL, 0
msg_bye_kernel:			db 'Bye from Kernel!', ENDL, 0
msg_bye:			db 'Bye!', ENDL, 0


ax_label: 		db 'AX: 0x', 0
bx_label: 		db 'BX: 0x', 0
cx_label: 		db 'CX: 0x', 0
dx_label: 		db 'DX: 0x', 0
x_res_label: 	db 'x res:', 0
y_res_label: 	db 'y res:', 0
bpp_label:		db 'bpp:', 0

sample:			db '0123456789ABCDEF'

%endif