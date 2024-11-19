# How to build ?

## Prerequisites

To build ELKS, you need a development environment on Linux or macOS or Windows with [WSL](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux), including:
- libncurses5-dev
- compress (for compressed man pages; use `sudo apt-get install ncompress`)
- texinfo

## Build steps

1- Configure the kernel, the user land and the target image format. This
creates the configuration file .config:

`make menuconfig`

2- Build the toolchain, kernel, the user land and the target image:

`make all`

If this is the first time ELKS is being built, the build system will fetch and
prepare the GCC-IA16 toolchain for you. This step takes some time, but will only
be performed on the first build of ELKS.

The target root folder is built in `target`, and depending on your
configuration, that folder is used to create either a floppy disk image
(fd360, fd720, fd1200, fd1440, fd2880), a flat 32MB hard disk image (without MBR),
or a ROM file image into the `image` folder. The image extension is '.img'
and will be in either ELKS (MINIX) or MSDOS (FAT) filesystem format.

3- Before writing that image on the real medium, you can test it first on QEMU:

`./qemu.sh`

4- You can then modify the configuration or the sources and repeat from the
step 4 after cleaning only the kernel, the user land and the image:

`make clean`

To clean the kernel build objects only, `make kclean` can be used.

5- One can also build ELKS distribution images for the entire suite of
supported floppy formats and hard disks (with and without MBRs) for both
MINIX and MSDOS FAT format. To create these images, use the following:

`make images`
