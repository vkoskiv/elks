#!/usr/bin/env bash

# This build script is called in main.yml by GitHub Continuous Integration
# Full build (including the cross tool chain)

set -e

SCRIPTDIR="$(dirname "$0")"

clean_exit () {
	E="$1"
	test -z $1 && E=0
	if [ $E -eq 0 ]
		then echo "Build script has completed successfully."
		else echo "Build script has terminated with error $E"
	fi
	exit $E
}

# TODO: Ideally, these would just be steps directly in the CI main.yml,
# but leaving these here as-is for now.

# Configure all

# FIXME: Does it make sense to generate a .config, only to then overwrite it
# immediately? This was intentionally added in ebeff4f66f, so I assume I'm
# missing something.
echo "Invoking 'make defconfig'..."
make defconfig || clean_exit 2
echo "Building IBM PC image..."
#cp ibmpc-1440.config .config
cp ibmpc-1440-nc.config .config

test -e .config || clean_exit 3

# Clean kernel, user land and image

# Build default kernel, user land and image
# Forcing single threaded build because of dirty dependencies (see #273)

echo "Building all..."
make -j1 all || clean_exit 4

# Possibly build all images

echo "Building all images..."
make images || clean_exit 5

# Build 8018X kernel and image
echo "Building 8018X image..."
cp 8018x.config .config
make kclean || clean_exit 6
rm elkscmd/basic/*.o
make -j1 || clean_exit 7

# Build PC-98 kernel, some user land files and image
echo "Building PC-98 image..."
cp pc98-1232.config .config
make kclean || clean_exit 8
rm bootblocks/*.o
rm elkscmd/sys_utils/clock.o
rm elkscmd/sys_utils/ps.o
rm elkscmd/sys_utils/meminfo.o
rm elkscmd/sys_utils/beep.o
rm elkscmd/basic/*.o
rm elkscmd/nano-X/*/*.o
make -j1 || clean_exit 9

# Success

echo "Target image is in 'image' folder."
clean_exit 0
