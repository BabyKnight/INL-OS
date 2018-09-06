;
;	boot.s
;	Intel style Assembly language (Compiled by NASM)
;
; boot.s is loaded at 0x7c00 by the bios-startup routines

org 0x7c00

mov si, msg
call print_msg
jmp $ ;Infinite loop, hang there.

print_msg:
    mov al, [si]
    inc si
    cmp al, 0 ;Check if value in AL is zero (end of string)
    je exit
    call print_character 
    jmp print_msg
	ret

print_character:
    mov ah, 0x0e ;BIOS to print a charater on screen.
    mov bh, 0x00
    mov bl, 0x07
    ;mov bx, 15 ;set character color
    int 0x10 ;Call video interrupt
    ret

exit:
    ret

msg:
   db "Loading system ..."  
   db 0

times 510 - ($ - $$) db 0 ;Fill the rest of sector with 0
dw 0xaa55 ;Add boot signature at the end of bootloader
