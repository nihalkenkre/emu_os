%ifndef PRINT_STRING
%define PRINT_STRING

;
; Prints a string on the screen
; Params:
;	- ds:si points to string
;	- cx points to length of string, or 0, 
;		if 0 then print based on null terminated string
; 

[bits 16]
print_string:
	push si
	push ax

; 	cmp ecx, 0
; 	je .null_ter_loop

; .cx_loop:
; 	lodsb				; loads next character into reg al
	
; 	mov ah, 0x0E		
; 	mov bh, 0			; page number (text modes)
; 	int 0x10			; call bios interrupt

; 	dec cx
; 	cmp cx, 0
; 	jnz .cx_loop
; 	jmp .done

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

	ret

%endif