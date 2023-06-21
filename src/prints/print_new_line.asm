%ifndef PRINT_NEW_LINE
%define PRINT_NEW_LINE

[bits 16]
print_new_line:
    push bp
    mov bp, sp

    push si

    mov si, new_line
    call print_string

    pop si

    mov sp, bp
    pop bp

    ret

new_line: db 0x0a, 0

%endif