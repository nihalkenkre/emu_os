%ifndef PRINT_STRING
%define PRINT_STRING

;
; Prints a string on the screen
; Params:
;	- ds:si points to string
; 

[bits 16]
print_string:
	push bp
	mov bp, sp

	push si
	push ax

.null_ter_loop:
	lodsb				; loads next character into reg al
	
	or al, al
	jz .done
	
	mov ah, 0x0E		
	mov bh, 0			; page number (text modes)
	int 0x10			; call bios interrupt

	jmp .null_ter_loop
	
.done:
	pop ax
	pop si

	mov sp, bp
	pop bp

	ret

%endif