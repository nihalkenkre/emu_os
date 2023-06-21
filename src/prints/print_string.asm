%ifndef PRINT_STRING
%define PRINT_STRING

%include "./src/prints/cursor_position.asm"

;
; Prints a string on the screen
; Params:
;	ds:si points to string
;	dx: current cursor position 
;
[bits 16]
print_string:
	push bp
	mov bp, sp

	push si
	push ax
	push bx

	mov ah, 0x9
	mov cx, 1

	add dh, [top_padding]
	add dl, [left_padding]
	call set_cursor_position

.null_ter_loop:
	lodsb
	
	or al, al
	jz .done

	cmp al, 0x0a
	je .new_line
	cmp al, 0x0d
	je .new_line

	int 0x10						; print the char
	
	inc dl							; move cursor to right
	call set_cursor_position

	jmp .null_ter_loop

.new_line:
	inc dh							; move cursor down
	xor dl, dl						; move cursor to the start of the line
	call set_cursor_position

	push cx
	mov cl, [si]
	
	or cl, cl
	pop cx
	jz .done

	add dl, [left_padding]
	call set_cursor_position

	jmp .null_ter_loop
	
.done:
	pop bx
	pop ax
	pop si

	mov sp, bp
	pop bp

	ret

is_selected: db 0

%endif