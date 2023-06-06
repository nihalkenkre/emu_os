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

	mov edi, 0x8000  		; di contains the destination for the file data copy. This will be popped and pushed as needed
	mov eax, sector_size
	mul ecx					; Mult sector size with the number of sectors for kernel
	add edi, eax				; Add to the destination

	; App addresses are stored in the sector starting from 0x8200
	; 0x8200 - the number of apps 
	; 0x8202::0x83ff -  the 16 bits locations of the app data

	mov [apps.locations], edi
	inc word [apps.locations]
	inc word [apps.locations]

	add edi, sector_size			; add 1 sector; this sector is for writing the start location of the app data

	; Calculate the maximum number of apps in the emufs table
	xor edx, edx
	mov eax, emufs_table_size
	mov ecx, emufs_table_entry_size
	div ecx					; ax contains the max number of app entries

	mov ecx, eax				; table entry loop counter
	mov edx, 1				; start from the 2nd file table entry, kernel is the 1st


.table_entry_loop:
	; Load the apps at locations starting at 0x8000 + kernel size
	push edx							; push the index since it is overriden by the mul
	push edi							; push the latest di after load sectors, for next app location

	mov eax, emufs_table_entry_size
	mul edx							; the offset from 0x7e00 of the current table entry is in eax

	add eax, 0x7e00	 				; ax contains the mem location of the table entry

	; add 10 to get the location of offset
	add eax, 10

	mov esi, eax
	mov edi, emufs_table_entry_offset_value
	movsw							; moves word from ds:si to es:di

	mov edi, emufs_table_entry_size_value
	movsw							; moves word from ds:si to es:di
	pop edi							; restore the latest di after load sectors, for next app location
	
	cmp [emufs_table_entry_size_value], word 0	; if entry size is 0 there is no file present
	je .table_entry_end

.calculate_num_sectors:
	xor edx, edx
	xor	eax, eax

	push ecx							; push the table entry count

	mov eax, [emufs_table_entry_size_value]
	mov ecx, sector_size
	div ecx							; divides dx:ax by operand, quotient in ax, remainder in dx

	cmp edx, 0
	je .calculate_start_sector

	inc eax							; Assumption is if dx is not 0, it will be between 0 and 512, so need to load one more sector
	
.calculate_start_sector:
    ; calculate the start sector number to load
    ; (offset of the file / the size of 1 sector) + 1
	push eax							; push the number of sectors to later use

	xor edx, edx
	xor eax, eax
	mov eax, [emufs_table_entry_offset_value]
	mov ecx, sector_size
	div ecx							; always divides the value in dx:ax by the operand. quotient in ax, remainder in dx

	inc eax							; + 1
	mov ebx, eax						; move start sector to ebx for load_sectors

	pop eax							; get back the number of sectors
	mov ecx, eax						; move the number of sectors to ecx for load_sectors

.load_sectors:
	; Store the memory locations of the app data for later use

	push eax
	push ecx
	push edi
	push esi

	mov eax, edi						; store the value of di into ax since we need to store the value of si
	mov edi, [apps.locations]

	xor ecx, ecx
	mov ecx, [apps.count]

	cmp ecx, 0
	jz .app_count_loop_end

.apps_count_loop:
	add edi, 2						; increment di to get the location where to store the addr of the next app data

	dec ecx
	jnz .apps_count_loop

.app_count_loop_end:
	stosw							; store the value of ax to the location pointed by es:di

	pop esi
	pop edi
	pop ecx	
	pop eax

	inc byte [apps.count]
	call load_sectors

	pop ecx
	pop edx

	inc edx
	cmp edx, ecx
	jne .table_entry_loop

.table_entry_end:

	; write the number of apps to 0x8200

	push esi
	push edi

	mov esi, apps.count
	mov edi, 0x8200

	movsw

	pop edi
	pop esi

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
emufs_table_entry_size equ 14		; 10 bytes for name + 2 bytes for offset + 2 for size

sector_size equ 512

emufs_table_entry_offset_value: dw 0
emufs_table_entry_size_value: 	dw 0

apps:
	.locations: dw 0
	.count: dw 0

%endif