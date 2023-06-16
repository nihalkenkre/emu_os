%ifndef PRINT_FILE_MENU
%define PRINT_FILE_MENU

%include "./src/prints/print_new_line.asm"
; 
; Print the names of the file present in the disk
;
; Params:
;   dx: cursor position
;
[bits 16]
print_file_menu:
    push bp
    mov bp, sp

    ; Go through the emufs file table and print out the names of the files
    ; File Table: 10 bytes filename + 4 bytes file offset from start + 4 bytes file size

    mov si, emufs_table_addr
    add si, 18                         ; skip the first entry which is the kernel entry

    mov byte [num_files], 0

.table_loop:
    ; Check to see if the size of in the file entry table is 0
    ; if it is zero, there is no file present there and after
    mov bx, si
    add bx, emufs_table_entry_size_value_offset
    cmp dword [bx], 0

    je .table_loop_end

    push si                             ; store the si which can be used later to jump to next entry

    xor ax, ax
    mov al, [current_selection_index]
    cmp al, [num_files]                 ; check if current file index is selected
    jne .not_selected
    
.selected:
    mov byte [is_selected], 1
    mov byte [char_color], 0x4f
    jmp .continue

.not_selected:
    mov byte [is_selected], 0
    mov byte [char_color], 0x1f
    jmp .continue

.continue:
    ; Store the dx values before printing the file names
    ;   These can be used for highlighting the current selection
    xor ax, ax
    mov al, [num_files]

    push di
    push dx

    xor bx, bx 
    mov bx, 2
    mul bx
    pop dx
    
    xor bx, bx                        
    mov bx, dx_for_file_labels        ; This is the base address, ax contains the 'offset'

    add ax, bx 

    mov di, ax
    mov ax, dx
    stosw

    pop di

    inc byte [num_files]                ; increment num files variable

    mov byte [top_padding], 0
    mov byte [left_padding], 29
    xor bx, bx
    mov byte bl, [char_color]
    call print_string                   ; print the file name until null char. TODO: limit the file name printing to 10 bytes max.
    call print_new_line

    pop si
    
    add si, emufs_table_entry_size     ; jump to the next table entry

    jmp .table_loop

.table_loop_end:
    mov sp, bp
    pop bp

    ret

dx_for_file_labels: times 10 dw 0                 ; Allocating space for 10 dx for now. TODO: Make storage dynamic
char_color: db 0x1f

max_filename_len equ 10
emufs_table_addr equ 0x7e00
emufs_table_entry_size equ 18
emufs_table_entry_size_value_offset equ 14

%endif