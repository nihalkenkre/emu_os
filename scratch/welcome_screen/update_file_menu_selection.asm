%ifdef VBE
%ifndef UPDATE_FILE_MENU_SELECTION
%define UPDATE_FILE_MENU_SELECTION

[bits 32]
update_file_menu_selection:
    push ebp
    mov ebp, esp

    xor edx, edx
    mov dl, [current_selection]
    mov edi, [edi_for_file_labels]
    call print_file_menu

.loop_end:
    mov esp, ebp
    pop ebp

    ret


current_selection: db 0                            ; Starting from 0 to num_files - 1

%endif
%endif