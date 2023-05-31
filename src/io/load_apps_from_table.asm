%ifndef LOAD_APPS_FROM_TABLE
%define LOAD_APPS_FROM_TABLE

;
; Load the app data from the emufs table into memory starting
; at 0x8000 + kernel size
;
; Params:
;   bx: start sector of kernel data
;   cx: number of sectors of kernel data
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

	mov di, 0x8000  		; This is the destination for the file data copy. This will be popped and pushed as needed
	mov ax, sector_size
	mul cx					; Mult sector size with the number of sectors for kernel
	add di, cx				; Add to the destination
	push di

	; Calculate the maximum number of apps in the emufs table
	xor dx, dx
	mov ax, emufs_table_size
	mov cx, emufs_table_entry_size
	div cx					; ax contains the max number of app entries

	mov cx, ax				; table entry loop counter
	mov dx, 1				; start from the 2nd file table entry, kernel is the 1st


.table_entry_loop:
	; Load the apps at locations starting at 0x8000 + kernel size
	push dx							; push the index since it is overriden by the mul

	mov ax, emufs_table_entry_size
	mul dx							; the offset from 0x7e00 of the current table entry is in eax

	add ax, 0x7e00	 				; ax contains the mem location of the table entry

	; add 10 to get the location of offset
	add ax, 10

	mov si, ax
	mov di, emufs_table_entry_offset_value
	movsw							; moves word from ds:si to es:di

	mov di, emufs_table_entry_size_value
	movsw							; moves word from ds:si to es:di
	
	pop dx							; pop the index for loop compare

	cmp [emufs_table_entry_size_value], word 0	; if entry size is 0 there is no file present
	je .table_entry_end

	pop di							; get the destination 0x8000 + kernel size + file sizes

.calculate_num_sectors:
.calculate_start_sector:

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

sector_size equ 512

emufs_table_entry_offset_value: dw 0
emufs_table_entry_size_value: 	dw 0

%endif