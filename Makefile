#
# Makefile for July OS.
#
all:	Image

Image: boot/boot

# set file extension as img at the moment
boot/boot: boot/boot.s
	nasm boot/boot.s -f bin -o boot.img 	

init/main.o: init/main.c

clean:
	rm boot.img
