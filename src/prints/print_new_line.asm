%ifndef PRINT_NEW_LINE
%define PRINT_NEW_LINE

;
; Prints a new line to the screen, using int10 commands
;

[bits 16]
print_new_line:
	push ax
	mov ah, 0x0e
	mov al, 0xd
	int 0x10

	mov al, 0xa
	int 0x10
	pop ax

	ret	

%endif