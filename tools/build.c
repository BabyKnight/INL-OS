/*
 *  tools/build.c
 *
 *  (C) 2022 Vincent Hu
 *
 *  This file builds a disk-image from 3 different files:
 *
 *  - boot: max 510 bytes of loaders
 *  - setup: max 4 sectors, sets up system parm
 *  - system: actual system
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>


void die(char *str)
{
		fprintf(stderr, "%s\n", str);
		exit(1);
}

void usage(void)
{
		die("Usage: build bootsect setup system [> image]");
		exit(1);
}

int main(int argc, char **argv)
{
		int i, fd; /* i for bytes read from boot file */
		char buf[1024];

		/* arguments should contain bootesct, setup and system */
		if (argc != 4)
				usage();

		/* Open bootsect file */
		if((fd=open(argv[1], O_RDONLY)) == -1)
				die("Unable to open 'boot'");

		i=read(fd, buf, sizeof buf);
		buf[510]=0x55;
		buf[511]=0xAA;
		i=write(1,buf,512);
		close(fd);
}
