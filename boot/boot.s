!
!	boot.s            (C) 2018 Vinent Hu
!
!	Intel style Assembly language
!
! boot.s is loaded at 0x7c00 by the bios-startup routines, and moves
! itself out of the way to address 0x90000, and jump there.
!
! It then loads 'setup' directly after itself (0x90200), and the system
! at 0x10000, using BIOS interrupts.

! SYSSIZE is the number of clicks (16bytes) to be loaded.
! 0x3000 is 0x30000 bytes = 196kB, more than enough for current versions of this OS

! Since the code of bootsect and setup will be move to the memory start from 0x90000,
! so SYSSIZE should no large than 0x9000 (584KB)
!
SYSSIZE = 0x3000

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
	movw                ! move bootsect itself to address 0x90000  (256 * 2 Bytes)
	jmpi go, INITSEG    ! jump to address 0x90000 and execute

go:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, #0xFF00     ! Top of the stack - ss:sp address is 0x9FF00

	mov ah, #0x03       ! read cursor pos
	xor bh, bh
	int 0x10

	mov cx, #24
	mov bx, #0x0007
	mov bp, #msg1
	mov ax, #0x1301
	int 0x10

msg1:
	.byte 13,10
	.ascii "VNL OS  - Loading system ..."
	.byte 13,10,13,10

! times 510 - ($ - $$) db 0 ! Fill the rest of sector with 0
! dw 0xaa55 !Add boot signature at the end of bootloader

.org 510
boot_flag:
	.word 0xAA55

.text
endtext:
.data
enddata:
.bss
endbss:
