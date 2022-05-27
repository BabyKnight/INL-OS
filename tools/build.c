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


#define MINIX_HEADER 32

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

		/* Initial buf with 0 */
		for (i=0; i<sizeof buf; i++)
				buf[i]=0;

		/* Open bootsect file */
		if((fd=open(argv[1], O_RDONLY)) == -1)
				die("Unable to open 'boot'");

		if (read(fd,buf,MINIX_HEADER) != MINIX_HEADER)
			die("Unable to read header of 'boot'");

		i=read(fd, buf, sizeof buf);
		fprintf(stderr, "Boot sector totally %d bytes.\n", i);
		if (i != 512)
				die("Boot block may not exceed 512 bytes");

		fprintf(stderr, "boot flag at 510 is [%x], 511 is [%x]\n", buf[510], buf[511]);
		if (buf[510] != 0x55 && buf[511] != 0xAA)
				die("Boot flag not found");

		i=write(1,buf,512);
		fprintf(stderr, "Total length of boot sector is [%d]\n", i); // debug
		if (i != 512)
				die("Write call failed");

		char filling_data[240*1024] = {0x00};
		i=write(1,filling_data, 240*1024);

		close(fd);
}
