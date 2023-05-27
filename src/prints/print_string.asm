%ifndef PRINT_STRING
%define PRINT_STRING

;
; Prints a string on the screen
; Params:
;	- ds:si points to string
;	- cx points to length of string

print_string:
	push si
	push ax

.loop:
	lodsb				; loads next character into reg al
	
	mov ah, 0x0E		
	mov bh, 0			; page number (text modes)
	int 0x10			; call bios interrupt

	dec cx
	cmp cx, 0
	jnz .loop
	
.done:
	pop ax
	pop si

	ret

%endif