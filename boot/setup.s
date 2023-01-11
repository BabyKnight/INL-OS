!
!	setup.s            (C) 2022 Vinent Hu
!
!	Intel style Assembly language
!
! setup.s is responsible for getting the system data from the BIOS, and putting them
! into the appropriate places in system memory.
! both setup.s and system has been loaded by the boot.s.
!
! setup.s asks the BIOS for memory/disk/other parameters, and put them in a "safe"
! place: 0x90000 ~ 0x901FF, where the bootsector used to be.
! Then enter to the protected mode, system to read them from there before the area is
! overwritten for buffer-blocks.
!


INITSEG  = 0x9000            ! move bootsect here
SETUPSEG = 0x9020            ! setup starts here, and this is the current segment
SYSSEG   = 0x1000            ! system loaded at 0x10000 (65536)

.globl begtext, begdata, begbss, endtext, enddata, endbss
.text
begtext:
.data
begdata:
.bss
begbss:
.text

entry start
start:

