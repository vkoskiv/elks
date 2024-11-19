export TOPDIR := $(shell pwd)
export CROSSDIR := $(TOPDIR)/cross
ELKSTOOLS_BIN := $(TOPDIR)/elks/tools/bin
ELKSCROSS_BIN := $(CROSSDIR)/bin

PATH := $(PATH):$(ELKSCROSS_BIN):$(ELKSTOOLS_BIN)
SHELL := env PATH=$(PATH) /bin/bash

include $(TOPDIR)/Make.defs

.PHONY: all cross toolchain clean libc kconfig defconfig config menuconfig image images kclean

all: toolchain .config include/autoconf.h
	$(MAKE) -C libc all
	$(MAKE) -C libc DESTDIR='$(TOPDIR)/cross' install
	$(MAKE) -C elks all
	$(MAKE) -C bootblocks all
	$(MAKE) -C elkscmd all
	$(MAKE) -C image all
ifeq ($(shell uname), Linux)
	$(MAKE) -C elksemu PREFIX='$(TOPDIR)/cross' elksemu
endif

cross:
	mkdir -p "$(CROSSDIR)"

toolchain: cross
	$(MAKE) -C tools all

prune-toolchain: toolchain
	$(MAKE) -C tools prune

# FIXME: Restructure dependencies instead of slapping toolchain on all of these
image: toolchain
	$(MAKE) -C image

images: toolchain
	$(MAKE) -C image images

kimage: kernel image

kernel: toolchain
	$(MAKE) -C elks

kclean: toolchain
	$(MAKE) -C elks kclean

# FIXME: 'clean' target of libc depends on ia16-elf-gcc, which seems suspect
# Remove toolchain dependency once resolved
clean: toolchain
	$(MAKE) -C libc clean
	$(MAKE) -C libc DESTDIR='$(TOPDIR)/cross' uninstall
	$(MAKE) -C elks clean
	$(MAKE) -C bootblocks clean
	$(MAKE) -C elkscmd clean
	$(MAKE) -C image clean
ifeq ($(shell uname), Linux)
	$(MAKE) -C elksemu clean
endif
	@echo
	@if [ ! -f .config ]; then \
	    echo ' * This system is not configured. You need to run' ;\
	    echo ' * `make config` or `make menuconfig` to configure it.' ;\
	    echo ;\
	fi

libc:
	$(MAKE) -C libc DESTDIR='$(TOPDIR)/cross' uninstall
	$(MAKE) -C libc all
	$(MAKE) -C libc DESTDIR='$(TOPDIR)/cross' install

elks/arch/i86/drivers/char/KeyMaps/config.in:
	$(MAKE) -C elks/arch/i86/drivers/char/KeyMaps config.in

kconfig:
	$(MAKE) -C config all

defconfig:
	$(RM) .config
	@yes '' | ${MAKE} config

include/autoconf.h: .config
	@yes '' | config/Configure -D config.in

config: elks/arch/i86/drivers/char/KeyMaps/config.in kconfig
	config/Configure config.in

menuconfig: elks/arch/i86/drivers/char/KeyMaps/config.in kconfig
	config/Menuconfig config.in

.PHONY: tags
tags:
	ctags -R --exclude=cross --exclude=elkscmd .
