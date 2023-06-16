%ifndef PRINT_FILE_MENU
%define PRINT_FILE_MENU

%include "./src/vbe/prints/print_string.asm"
%include "./src/vbe/prints/print_new_line.asm"

[bits 32]
print_file_menu:
    push ebp
    mov ebp, esp

    ; Go through the emufs file table and print out the names of the files
    ; File Table: 10 bytes filename + 4 bytes file offset from start + 4 bytes file size

    mov esi, 0x7e00
    add esi, 18                         ; skip the first entry which is the kernel entry

.table_loop:
    ; first check to see if the size of in the file entry table is 0
    ; if it is zero, there is no file present there and after
    mov ebx, esi
    add ebx, emufs_table_entry_size_value_offset
    cmp dword [ebx], 0

    je .table_loop_end

    push esi                        ; store the esi which can be used later to jump to next entry

    inc byte [num_files]

    mov dword [top_padding], 1
    mov dword [left_padding], 28
    call print_string_vbe

    pop esi
    
    ; mov dword [top_padding], 0
    ; mov dword [left_padding], 0
    ; call print_new_line_vbe

    add esi, emufs_table_entry_size

    jmp .table_loop


.table_loop_end:

    mov esp, ebp
    pop ebp

    ret

num_files: db 0
max_filename_len equ 10
emufs_table_entry_size equ 18
emufs_table_entry_size_value_offset equ 14

%endif