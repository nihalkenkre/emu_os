%ifndef LOAD_APPS_FROM_TABLE
%define LOAD_APPS_FROM_TABLE

%include "./src/io/load_sectors.asm"

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

    push ax
    push bx
    push cx
	push dx
	push si
	push di

	mov di, 0x8000  		; di contains the destination for the file data copy. This will be popped and pushed as needed
	mov ax, sector_size
	mul cx					; Mult sector size with the number of sectors for kernel
	add di, ax				; Add to the destination

	mov [apps.start_location], di

	add di, 0x200			; add 1 sector; this sector is for writing the start location of the app data


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
	push di							; push the latest di after load sectors, for next app location

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
	pop di							; restore the latest di after load sectors, for next app location
	
	cmp [emufs_table_entry_size_value], word 0	; if entry size is 0 there is no file present
	je .table_entry_end

.calculate_num_sectors:
	xor dx, dx
	xor	ax, ax

	push cx							; push the table entry count

	mov ax, [emufs_table_entry_size_value]
	mov cx, sector_size
	div cx							; divides dx:ax by operand, quotient in ax, remainder in dx

	cmp dx, 0
	je .calculate_start_sector

	inc ax							; Assumption is if dx is not 0, it will be between 0 and 512, so need to load one more sector
	
.calculate_start_sector:
	push ax							; push the number of sectors to later use

	xor dx, dx
	xor ax, ax
	mov ax, [emufs_table_entry_offset_value]
	mov cx, sector_size
	div cx

	inc ax
	mov bx, ax

	pop ax
	mov cx, ax

	call load_sectors

	pop cx
	pop dx

	inc dx
	cmp dx, cx
	jne .table_entry_loop

.table_entry_end:

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

    mov sp, bp
    pop bp

    ret

emufs_table_size equ 512
emufs_table_entry_size equ 14		; 10 bytes for name + 2 bytes for offset + 2 for size

sector_size equ 512

emufs_table_entry_offset_value: dw 0
emufs_table_entry_size_value: 	dw 0

apps:
	.start_location: dw 0
	.num_of_apps: db 0

%endif