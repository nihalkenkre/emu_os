%ifndef UPDATE_FILE_MENU_SELECTION
%define UPDATE_FILE_MENU_SELECTION

[bits 32]
update_file_menu_selection:
    push ebp
    mov ebp, esp

    mov esp, ebp
    pop ebp

    ret

current_selection: db 0

%endif