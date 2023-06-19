%ifndef UPDATE_FILE_MENU_SELECTION
%define UPDATE_FILE_MENU_SELECTION

[bits 32]
update_file_menu_selection:
    push ebp
    mov ebp, esp

    mov ecx, 0                          ; current file index

.loop:
    cmp byte ecx, [num_files]
    je .loop_end
    
    mov eax, 4
    mul ecx

    mov edi, [edi_for_file_labels + eax]

    inc byte ecx

    jmp .loop

.loop_end:
    mov esp, ebp
    pop ebp

    ret


current_selection: db 0                            ; Starting from 0 to num_files - 1


%endif