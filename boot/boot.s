;
;	boot.s
;
; boot.s is loaded at 0x7c00 by the bios-startup routines

org 0x7c00

mov si, msg
call PrintMsg
jmp $ ;Infinite loop, hang there.

PrintMsg:
    mov al, [si]
    inc si
    cmp al, 0
    je exit
    call PrintCharacter
    jmp PrintMsg

PrintCharacter:
    mov ah, 0x0e ;BIOS to print a charater on screen.
    mov bh, 0x00
    mov bl, 0x07
    ;mov bx, 15 ;set character color
    int 0x10 ;Call video interrupt
    ret

msg:
   db "Loading system ..."  
   db 0x0a

exit:
    ret

times 510 - ($ - $$) db 0 ;Fill the rest of sector with 0
dw 0xaa55 ;Add boot signature at the end of bootloader
