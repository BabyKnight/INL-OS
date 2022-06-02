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

SETUPLEN = 4                 ! len of setup-sectors, 4 sectors
BOOTSEG  = 0x07c0            ! original address of boot sector
INITSEG  = 0x9000            ! move bootsect here
SETUPSEG = 0x9020            ! setup starts here
SYSSEG   = 0x1000            ! system loaded at 0x10000 (65536)
ENDSEG   = SYSSEG + SYSSIZE  ! where to stop loading

! ROOT_DEV:  0x000 - same type of floopy as boot.
!            0x301 - first partition on first drive etc
!            0x306 - first partition on second drive etc
ROOT_DEV = 0x000

entry start
start:
	mov ax, #BOOTSEG
	mov ds, ax
	mov ax, #INITSEG
	mov es, ax

	! TODO for debug purpose, will delete later
	mov ah, #0x03             ! read cursor pos
	xor bh, bh                ! save the cursor pos to dx
	int 0x10                  ! dh=row (0~24), dl=coloum (0~79)
	mov cx, #18               ! totally 18 characters
	mov bx, #0x0007           ! page 0, attribute 7 (normal)
	mov bp, #msg1             ! es:bp point to the string to print
	mov ax, #0x1301           ! write string, move cursor
	int 0x10                  ! print the string and move cursor to the end
	!

	mov cx, #256
	sub si, si
	sub di, di
	rep
	movw                      ! move bootsect itself to address 0x90000  (256 * 2 Bytes)
	jmpi go, INITSEG          ! jump to address 0x90000 and execute

go:
	mov ax, cs
	mov ds, ax
	mov es, ax

	! TODO for debug purpose, will delete later
	mov ah, #0x03             ! read cursor pos
	xor bh, bh                ! save the cursor pos to dx
	int 0x10                  ! dh=row (0~24), dl=coloum (0~79)
	mov cx, #30               ! totally 30 characters
	mov bx, #0x0007           ! page 0, attribute 7 (normal)
	mov bp, #msg2             ! es:bp point to the string to print
	mov ax, #0x1301           ! write string, move cursor
	int 0x10                  ! print the string and move cursor to the end
	!

	mov ss, ax
	mov sp, #0xFF00           ! Top of the stack - ss:sp address is 0x9FF00

! load the setup-sectors directly

load_setup:
	mov dx, #0x0000           ! drive 0, head 0
	mov cx, #0x0002           ! sector 2, track 0, cl = start sectors (bit 0~5), drive number (bit 6~7)
	mov bx, #0x0200           ! address = 512, int INITSEG
	mov ax, #0x0200+SETUPLEN  ! - nr of sectors, al = number of sectors 
	int 0x13                  ! read it
	jnc ok_load_setup         ! load srtup complete, continue
	mov dx, #0x0000           ! read on drive 0
	mov ax, #0x0000           ! reset the diskette
	int 0x13
	j load_setup

ok_load_setup:
	! get disk drive parameters
	mov dl, #0x00             ! DL = drive num, (to set bit 7 to 1 if it's hard drive)
	mov ax, #0x0800           ! AH=8 is get drive parameters
	int 0x13
	mov ch, #0x00
	seg cs                    ! operand for next instruction store in CS
	mov sectors, cx
	mov ax, #INITSEG
	mov es, ax                ! since es has been modified, reset to #INITSEG

	! OK, we gonna print some message now
	mov ah, #0x03             ! read cursor pos
	xor bh, bh                ! save the cursor pos to dx
	int 0x10                  ! dh=row (0~24), dl=coloum (0~79)

	mov cx, #24               ! totally 24 characters
	mov bx, #0x0007           ! page 0, attribute 7 (normal)
	mov bp, #msg3             ! es:bp point to the string to print
	mov ax, #0x1301           ! write string, move cursor
	int 0x10                  ! print the string and move cursor to the end

	! Now, we want to load the system (at 0x10000)
	mov ax,#SYSSEG
	mov es,ax
	!!call read_it              ! read the system module from the disk
	!!call kill_motor           ! stop the motor of drive, so that we can know the status of the drive

	! Check the root device to use. If the device is defined (!=0). nothing is done and the given device
	! is used. Otherwise, either /dev/PS0 (2, 28) or /dev/at0 (2, 8), depending on the number of sectors
	! that the BIOS reports currently.
	seg cs
	mov ax, root_dev          ! check Byte 508 & 509 for root device whether is defined
	cmp ax, #0
	jne root_defined

	! sectors=15 means 1.2Mb drive, sectors=18 means 1.4Mb drive. Since it's bootable, should be A drive
	seg cs
	mov bx, sectors
	mov ax, #0x0208           ! /dev/ps0 - 1.2Mb
	cmp bx, #15
	je root_defined
	mov ax, #0x021c           ! /dev/PS0 - 1.44Mb
	cmp bx, #18
	je root_defined

undef_root:
	jmp undef_root            ! if it's different, infinite loop

root_defined:
	seg cs
	mov root_dev, ax          ! move the checked device to root_dev

	! everything is loaded, now jump to the SETUP at 0x90200
	jmpi 0, SETUPSEG



read_it:
	
kill_motor:


sectors:
	.word 0

msg4:
	.ascii "load setup done."
	.byte 13,10

msg1:
	.ascii "Bootsector found"
	.byte 13,10

msg2:
	.ascii "Moving bootsector to 0x90000"
	.byte 13,10

msg3:
	.byte 13,10
	.ascii "Loading system ..."
	.byte 13,10,13,10


.org 508
root_dev:
	.word ROOT_DEV

boot_flag:
	.word 0xAA55

.text
endtext:
.data
enddata:
.bss
endbss:
