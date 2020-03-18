/*
 * reboot.c
 *
 * Copyright 2000 Alistair Riddoch
 * ajr@ecs.soton.ac.uk
 *
 * This file may be distributed under the terms of the GNU General Public
 * License v2, or at your option any later version.
 */

/*
 * This is a small version of reboot for use in the ELKS project.
 * It is not fully functional, and may not be the most efficient
 * implementation for larger systems. It minimises memory usage and
 * code size.
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <time.h>
#include <sys/mount.h>
#include <sys/select.h>

int main(int argc, char **argv)
{
	sync();
	if (umount("/")) {
		perror("reboot umount");
		exit(1);
	}
	sleep(3);
	if (reboot(0x1D1E,0xC0DE,0x0123)) {
		perror("reboot");
		exit(1);
	}
}
