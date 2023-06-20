%ifndef CURSOR_POSITION
%define CURSOR_POSITION

;
; Sets the cursor position on the screen.
; Params:
;   dx: higher byte - row#, lower byte - col #
;
[bits 16]
set_cursor_position:
    push bp
    mov bp, sp

    push ax

    xor ax, ax
    mov ah, 0x2
    int 0x10

    pop ax

    mov sp, bp
    pop bp

    ret


%endif