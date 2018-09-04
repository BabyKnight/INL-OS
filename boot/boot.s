;
;	boot.s
;
; boot.s is loaded at 0x7c00 by the bios-startup routines

ORG 0x7C00

JMP $ ;Infinite loop, hang there.

TIMES 510 - ($ - $$) DB 0 ;Fill the rest of sector with 0
DW 0xAA55 ;Add boot signature at the end of bootloader 
