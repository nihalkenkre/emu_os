%ifndef LOAD_APPS_FROM_TABLE
%define LOAD_APPS_FROM_TABLE

;
; Load the app data from the emufs table into memory starting
; at 0x8000 + kernel size
;
; Params:
;   ebx: start sector of kernel data
;   ecx: number of sectors of kernel data
;
[bits 16]
load_apps_from_table:
    push bp
    mov bp, sp

    push bx
    push cx
	push dx
	push si
	push di

	; Calculate the maximum number of apps in the emufs table
	xor dx, dx
	mov ax, emufs_table_size
	mov cx, emufs_table_entry_size
	div cx			; eax contains the max number of app entries

	mov cx, ax	; table entry loop counter
	mov dx, 1		; start from the 2nd file table entry, kernel is the 1st

.table_entry_loop:
	; Load the apps at locations starting at 0x8000 + kernel size
	push dx							; push the index since it is overriden by the mul
	mov ax, emufs_table_entry_size
	mul dx							; the offset from 0x7e00 of the current table entry is in eax

	add ax, 0x7e00	 				; ax contains the mem location of the table entry
	add ax, 10

	mov si, ax
	; add 10 to get the location of offset
	mov di, emufs_table_entry_offset_value
	movsw

	; add 2 to get the location of size
	mov di, emufs_table_entry_size_value
	movsw
	
	pop dx							; pop the index for loop compare

	cmp [emufs_table_entry_size_value], word 0	; if entry size is 0 there is no file present
	je .table_entry_end
	
	inc dx
	cmp dx, cx
	jne .table_entry_loop

.table_entry_end:

	pop di
	pop si
	pop dx
	pop cx
	pop ax

    mov sp, bp
    pop bp

    ret

emufs_table_size equ 512
emufs_table_entry_size equ 14		; 10 bytes for name + 2 bytes for offset + 2 for size

emufs_table_entry_offset_value: dw 0
emufs_table_entry_size_value: 	dw 0

%endif