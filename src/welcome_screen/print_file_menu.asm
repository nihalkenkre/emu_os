%ifndef PRINT_FILE_MENU
%define PRINT_FILE_MENU

[bits 32]
print_file_menu:
    push ebp
    mov ebp, esp

    mov esp, ebp
    pop ebp

    ret

%endif