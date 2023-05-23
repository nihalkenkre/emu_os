org 0x7C00
bits 16

start:
	jmp main


print_new_line:
	push ax
	mov ah, 0x0e
	mov al, 0x0D
	int 10h

	mov al, 0x0A
	int 10h

	pop ax

	ret

;
; Prints a string on the screen
; Params:
;	- ds:si points to string
;
puts:
	push si
	push ax
	push bx
	push cx

.loop:
	lodsb				; loads next character into reg al
	or al, al 			; verify if the next character is null
	jz .done
	
	mov ah, 0x0E		
	mov bh, 0			; page number (text modes)
	int 0x10			; call bios interrupt
	
	jmp .loop

.done:
	pop cx
	pop bx
	pop ax
	pop si

	ret

;
; Convert LBA to CHS
; Parameters:
; 		ax = LBA 
; Result:
;		ch = cylinder number
;		dh = head number	
;		cl = sector number
; 
lba_to_chs:
	push ax
	push dx

	xor dx, dx 							; clear because div divides dx:ax by a value
										; ax contains the LBA

	div word [sectors_per_track]		; ax contains quotient which will keep as is, required.
										; dx contains remainder, which is sectors - 1

	inc dx								; Sectors is dx + 1
	mov cx, dx							

	xor dx, dx
	div word [head_count]				; ax contains quotient, which is Cylinder
										; dx contains remainder, which is Head
	mov dh, dl
	mov ch, al

	shl ah, 6
	or cl, ah

	pop ax
	mov dl, al
	pop ax

	ret

;
; Paramters:
;		ax: LBA
;		cl: number of sectors to read
;		dl: drive number
;		es:bx: mem location to copy the disk data
;
disk_read:
	push ax
	push bx
	push cx
	push dx
	push di

	call lba_to_chs

	mov ax, cx
	mov ah, 0x02

	mov di, 3

.retry:
	int 13h
	jnc .done

	dec di
	test di, di
	jnz .retry

.failed:
	mov si, msg_disk_read_error
	call puts 

	mov si, msg_reboot
	call puts

	mov ah, 0h
	int 16h

	jmp 0xffff:0				; BIOS starts at ffff:0000

.done:
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	
	ret

load_kernel:
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push es
	
	mov ax, 1
	mov cl, 1
	mov bx, 0x7e00

	call disk_read

	pop es
	pop di
	pop si
	pop dx
	pop cx
	pop bx	
	pop ax

	ret
	
main:
	; setup data segments
	mov ax, 0
	mov ds, ax
	mov es, ax
	cld

	; setup stack
	mov ss, ax
	mov sp, 0x7C00

	mov si, msg_loading

	call print_new_line
	call puts
	call print_new_line

	mov [drive_num], dl

	; get head_count and sectors_per_track from bios
	; push es
	; mov ah, 08h

	; int 13h						; dh = number of heads - 1, cx-[0:5] sectors per track

	; pop es

	; xor ch, ch
	; and cl, 0x3f

	; inc dh
	; mov [head_count], dh
	; mov [sectors_per_track], cx

	; call load_kernel

	; jmp 0x7e00

	; call print_new_line
	; call print_new_line
	; mov si, msg_bye
	; call puts

	cli

	lgdt [gdt_desc]

	mov eax, cr0
	or eax, 0x1
	mov cr0, eax

	jmp CODESEG:start_protected_mode

	hlt

.halt:
	jmp .halt

[bits 32]
start_protected_mode:
	mov al, 'A'
	mov ah, 0x0f
	mov [0xb8000], ax

	cli
	hlt

msg_loading			:db 'loading...', 0x0D, 0x0A, 0
msg_bye				:db 'Bye World!', 0x0D, 0x0A, 0
msg_disk_read_error	:db 'Read from disk failed!', 0x0D, 0x0A, 0
msg_reboot			:db 'Press any key to reboot...', 0x0D, 0x0A, 0
bytes_per_sector	:dw 512
sectors_per_track	:dw 18
head_count			:db 2
drive_num			:db 0
kernel_file_name	:db 'kernel.bin'

gdt_start:
	.null: 
		dd 0
		dd 0
	.code:
		dw 0xffff
		dw 0
		db 0
		db 0x9a
		db 11001111b
		db 0
	.data:
		dw 0xffff
		dw 0
		db 0
		db 0x92
		db 11001111b
		db 0
gdt_end:

gdt_desc:
	.size:  dw (gdt_end - gdt_start - 1)
	.offset: dd gdt_start

CODESEG equ gdt_start.code - gdt_start
DATASEG equ gdt_start.data - gdt_start

times 510-($-$$) db 0

dw 0AA55h
