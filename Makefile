#
# Makefile for OS I.
#
all:	Image

Image: boot/boot

boot/boot: boot/boot.s
	nasm boot/boot.s -f bin -o boot.img 	

clean:
	rm boot.img
