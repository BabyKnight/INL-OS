;
;	boot.s
;
; boot.s is loaded at 0x7c00 by the bios-startup routines

org 0x7c00

mov al, 65
call PrintMsg
jmp $ ;Infinite loop, hang there.

PrintMsg:
    mov ah, 0x0e
    mov bh, 0x00
    mov bl, 0x07

    int 0x10
    ret

times 510 - ($ - $$) db 0 ;Fill the rest of sector with 0
dw 0xaa55 ;Add boot signature at the end of bootloader
