#
# Makefile for INL OS.
#

#AS86	=as -0 -a
AS86	=as86 -0 -a

CC	=gcc
#CFLAGS	=-Wall -O -fstrength-reduce -fomit-frame-pointer -fcombine-regs
CFLAGS	=-Wall -O -fstrength-reduce -fomit-frame-pointer

all:	Image

Image: boot/boot tools/build
	tools/build boot/boot setup system > Image

tools/build:	tools/build.c
	$(CC) $(CFLAGS) -o tools/build tools/build.c

# set file extension as img at the moment
boot/boot: boot/boot.s
	$(AS86) -o boot/boot boot/boot.s

init/main.o: init/main.c

clean:
	rm Image tools/build boot/boot
