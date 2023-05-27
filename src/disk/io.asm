%ifndef IO
%define IO

%include "./src/utils/prints.asm"

emufs_filename_entry equ 10
emufs_table_size equ 512

bx_label: db 'BX: 0x'
bx_label_len: db ($ - bx_label)
;
; Load sectors from the master hard disk into memory
; Params:
;   bl      : number of sectors to read
;   cl      : first sector number to read from
;   es:di   : The memory address to copy data to
;
load_sectors:
    push bp
    mov bp, sp

    pusha

    mov dx, 0x1f6
    mov al, 0xa0
    out dx, al

    mov dx, 0x1f2
    mov al, bl
    out dx, al

    mov dx, 0x1f3
    mov al, cl
    out dx, al

    mov dx, 0x1f4
    xor al, al
    out dx, al

    mov dx, 0x1f5
    xor al, al
    out dx, al

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

.sector_loop:
.loop:
    in al, dx
    test al, 8
    je .loop

    mov cx, 256
    mov dx, 0x1f0
    rep insw

    dec bx
    cmp bx, 0

    ; ; print value of bx register
    ; push cx
    ; push si
    ; push bx
    ; mov si, bx_label
    ; mov cl, byte [bx_label_len]
    ; call print_reg
    ; call print_new_line
    ; pop bx
    ; pop si
    ; pop cx

    jnz .sector_loop

    popa

    mov sp, bp
    pop bp

    ret

;
; Take in a string and compare it will the file_name of the table entries,
; if exists returns the offset and size
;
; Params:
;   ds:si: file name string label
;   es:di: pointer to emufs table
;
; Returns:
;   al: 1 if filename found, 0 if filename not found
;   bx: offset
;   cx: size
;
; di is clobbered
;
get_filename_details:
    push edx
    push si

    ;; Look for the table entry with filename
    ; find number of table entries in table
    xor edx, edx
    mov eax, emufs_table_size       ; emufs table total size
    mov ecx, 14                     ; size of table entry: 10 byte file name + 2 byte offset from disk start + 2 byte size
    div ecx                         ; always divides the value in edx:eax by the operand. quotient in eax, remainder in edx

    ; eax contains the number of table entries
    ; Loop through table entries to find entry with filename

    mov ecx, eax        ; number of table entries to ecx

.table_loop:
    push ecx
    
.filename_loop:
    xor ecx, ecx
    mov cl, emufs_filename_len
    repe cmpsb
    jz .file_found

    ; Jump to the next table entry;
    add di, cx          ; add the remaining number of bytes to di
    add di, 4           ; and 2 bytes for offset; add 2 bytes for size

    mov bx, emufs_filename_len       
    sub bx, cx          ; Get the number chars that were matched
    sub si, bx          ; decrement si to go back to the start of the test string

    pop ecx
    dec ecx
    cmp ecx, 0
    jnz .table_loop

    jmp .file_not_found

.file_found:
    pop ecx                 ; we pushed the value before the filename loop

    xor eax, eax
    mov al, 0x1             ; return file found

    mov bx, word [es:di]    ; return file offset

    inc di
    inc di

    mov cx, word [es:di]    ; return 

    jmp .return

.file_not_found:
    xor eax, eax

    jmp .return

.return:
    pop si
    pop edx

    ret

%endif