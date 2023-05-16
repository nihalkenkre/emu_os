org 0x7C00
bits 16

boot:
	Jump:			   db 	0xEB, 0x3C, 0x90
    OEMname:           db   "mkfs.fat"  ; mkfs.fat is what OEMname mkdosfs uses
    bytesPerSector:    dw   512
    sectPerCluster:    db   1
    reservedSectors:   dw   1
    numFAT:            db   2
    numRootDirEntries: dw   224
    numSectors:        dw   2880
    mediaType:         db   0xf0
    numFATsectors:     dw   9
    sectorsPerTrack:   dw   18
    numHeads:          dw   2
    numHiddenSectors:  dd   0
    numSectorsHuge:    dd   0
    driveNum:          db   0x80
    reserved:          db   0
    signature:         db   0x29
    volumeID:          dd   0x2d7e5a1a
    volumeLabel:       db   "   EMU OS  "
    fileSysType:       db   "  FAT12 "

start:
	jmp main

;
; Prints a string on the screen
; Params:
;	- ds:si points to string
;
puts:
	push si
	push ax

.loop:
	lodsb				; loads next character into reg al
	or al, al 			; verify if the next character is null
	jz .done
	
	mov ah, 0x0E		
	mov bh, 0			; page number (text modes)
	int 0x10			; call bios interrupt
	
	jmp .loop

.done:
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
	div word [sectorsPerTrack]			; ax contains quotient which will keep as is, required.
										; dx contains remainder

	inc dx								; Sectors is dx + 1
	mov cx, dx							

	xor dx, dx
	div word [numHeads]					; ax contains quotient, which is Cylinder
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

	; jmp 0xffff:0				; BIOS starts at ffff:0000

.done:
	pop di
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

	mov si, msg_hello

	call print_new_line
	call puts
	call print_new_line



	mov [driveNum], dl
	mov ax, 1
	mov cl, 1
	mov bx, 0x7e00
	call disk_read

	call print_new_line
	call print_new_line
	mov si, msg_bye
	call puts

	cli
	hlt


print_new_line:
	push ax
	mov ah, 0x0e
	mov al, 0x0D
	int 10h

	mov al, 0x0A
	int 10h

	pop ax

	ret

.halt:
	jmp .halt

msg_hello			:db 'Hello World!', 0x0D, 0x0A, 0
msg_bye				:db 'Bye World!', 0x0D, 0x0A, 0
msg_disk_read_error	:db 'Read from disk failed!', 0x0D, 0x0A, 0

times 510-($-$$) db 0

dw 0AA55h
