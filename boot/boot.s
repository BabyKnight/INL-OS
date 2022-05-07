!
!	boot.s            (C) 2018 Vinent Hu
!	Intel style Assembly language (Compiled by NASM)
!
! boot.s is loaded at 0x7c00 by the bios-startup routines, and moves
! itself out of the way to address 0x90000, and jump there.
!
! It then loads 'setup' directly after itself (0x90200), and the system
! at 0x10000, using BIOS interrupts.


.globl begtext, begdata, begbss, endtext, enddata, endbss
.text
begtext:
.data
begdata:
.bss
begbss:
.text

BOOTSEG  = 0x07c0            ! original address of boot sector
INITSEG  = 0x9000            ! move bootsect here
SETUPSEG = 0x9020            ! setup starts here
SYSSEG   = 0x1000            ! system loaded at 0x10000 (65536)
ENDSEG   = SYSSEG + SYSSIZE  ! where to stop loading

entry start
start:
	mov ax, #BOOTSEG
	mov ds, ax
	mov ax, #INITSEG
	mov es, ax
	mov cx, #256
	sub si, si
	sub di, di
	rep
	movw            ! move bootsect itself to address 0x90000  (256 * 2 Bytes)
	jmpi go, INITSEG    ! jump to address 0x90000 and execute

go:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, #0xFF00     ! Top of the stack - ss:sp address is 0x9FF00



! ok, print loading message
mov si, msg
call print_msg
jmp $ !Infinite loop, hang there.

print_msg:
    mov al, [si]
    inc si
    cmp al, 0 !Check if value in AL is zero (end of string)
    je exit
    call print_character 
    jmp print_msg
	ret

print_character:
    mov ah, 0x0e !BIOS to print a charater on screen.
    mov bh, 0x00
    mov bl, 0x07
    !mov bx, 15 !set character color
    int 0x10 !Call video interrupt
    ret

exit:
    ret

msg:
   db "Loading system ..."  
   db 0

times 510 - ($ - $$) db 0 !Fill the rest of sector with 0
dw 0xaa55 !Add boot signature at the end of bootloader
