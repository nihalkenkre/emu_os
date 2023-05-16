org 0x7C00
bits 16

; %define ENDL 0x0D, 0x0A

; start:
; 	jmp main

; ;
; ; Prints a string on the screen
; ; Params:
; ;	- ds:si points to string
; ;
; puts:
; 	push si
; 	push ax

; .loop:
; 	lodsb				; loads next character into reg al
; 	or al, al 			; verify if the next character is null
; 	jz .done
	
; 	mov ah, 0x0E		
; 	mov bh, 0			; page number (text modes)
; 	int 0x10			; call bios interrupt
	
; 	jmp .loop

; .done:
; 	pop ax
; 	pop si
; 	ret

; main:
; 	; setup data segments

; 	mov ax, 0
; 	mov ds, ax
; 	mov es, ax

; 	; setup stack

; 	mov ss, ax
; 	mov sp, 0x7C00

; 	mov si, msg_hello
; 	call puts

; 	cli
; 	hlt

; .halt:
; 	jmp .halt

; msg_hello: db 'Hello World!', ENDL, 0

times 510-($-$$) db 0xCF 
dw 0AA55h
