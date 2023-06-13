%ifndef LOAD_APPS_FROM_TABLE_32
%define LOAD_APPS_FROM_TABLE_32

%include "./src/io/load_sectors_32.asm"
;
; Load the app data from the emufs table into memory starting
; at 0x100000 (1MB mark). SUBJECT TO CHANGE.
;
; Memory Map:
;	0x7c00 - bootloader
;	0x7e00 - emu fs table
;	0x8000 - kernel
; 	0x**** - array of locations of the app data, starts after kernel sectors
; 0x100000 - start of app data
;
; Params:
;   ebx: start sector of kernel data
;   ecx: number of sectors of kernel data
;	edi: the addr just after the kernel data, where the app data locations can be stored
;
[bits 32]
load_apps_from_table:
    push ebp
    mov ebp, esp

    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

	mov edx, edi					; Store the start addr of app location to edx
	mov edi, 0x100000				; Store the app data location to edi
	mov esi, 0x7e00 				; Start of the emu fs table.
	add esi, 18						; add 18 to skip the 18 bytes for the kernel

	; A Table entry is 10 bytes filename + 4 bytes offset + 4 bytes size

.table_loop:

	add esi, 10										; add 10 to skip the bytes for the filename

	push edi										; save the start addr of the app locations
	mov edi, emufs_table_entry_offset_value
	movsd

	mov edi, emufs_table_entry_size_value
	movsd
	pop edi											; get the start addr of the app locations

	cmp dword [emufs_table_entry_size_value], 0
	jz .table_loop_end

	; We have to store the value of edi to the mem location pointed to by eax.
	; we get the value of edi into eax and value of edx into edi for the stosd opcode.

	push edi										; save the app data location

	mov eax, edi
	mov edi, edx
	stosd											; store the value of eax to the mem pointed by edi
	mov edx, edi									; store the auto incremented edi to edx to point to the next mem location to store the next app location

	pop edi											; restore the app data location


.calculate_start_sector:
    ; calculate the start sector number to load
    ; (offset of the file / the size of 1 sector) + 1
	mov eax, [emufs_table_entry_offset_value]
	mov ecx, sector_size

	push edx

	xor edx, edx
	div ecx
	inc eax				; + 1

	mov ebx, eax		; mov offset to ebx for load_sectors

.calculate_num_sectors:
	mov eax, [emufs_table_entry_size_value]
	mov ecx, sector_size

	xor edx, edx
	div ecx				; num sectors in eax, and remainder bytes in edx

	cmp edx, 0
	je .load_sectors
	inc eax				; Assumption is if edx is not 0, it will be between 0 and 512, so need to load one more sector

.load_sectors:
	mov ecx, eax		; mov num sectors to ecx for load_sectors
	pop edx

	call load_sectors

	jmp .table_loop

.table_loop_end:

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp

    ret

emufs_table_size equ 512
emufs_table_entry_size equ 18		; 10 bytes for name + 4 bytes for offset + 4 for size

sector_size equ 512

emufs_table_entry_offset_value: dd 0
emufs_table_entry_size_value: 	dd 0

%endif