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

    push ebx
    push ecx

	; Calculate the maximum number of apps in the emufs table
	xor edx, edx
	mov eax, emufs_table_size
	mov ecx, emufs_table_entry_size
	div ecx			; eax contains the max number of app entries

	mov ecx, eax	; table entry loop counter
	mov edx, 1		; start from the 2nd file table entry, kernel is the 1st

.table_entry_loop:
	; Load the apps at locations starting at 0x8000 + kernel size
	
	inc edx
	cmp edx, ecx
	jne .table_entry_loop


    pop bp
    mov sp, bp

    ret

emufs_table_size equ 512
emufs_table_entry_size equ 14		; 10 bytes for name + 2 bytes for offset + 2 for size

%endif