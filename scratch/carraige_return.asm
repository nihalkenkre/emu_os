; bring edi to the start of the current line
;
; To go to the 'start' of the line, we first
; subtract the current memory location from the base memory_location
; edi - phy_base_ptr
;
; and do a bytes_per_scan_line / x_resolution. The remainder is the number of locations from the 'start' of the line
; 
xor edx, edx
xor eax, eax

mov eax, edi
sub eax, [mode_info_block.phy_base_ptr]

xor ebx, ebx
mov bx, [mode_info_block.lin_bytes_per_scan_line]
div ebx                                                     ; quotient is in eax, modulo is in edx

sub edi, edx                                                ; pointer at the start of the new line