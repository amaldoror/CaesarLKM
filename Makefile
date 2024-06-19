#!/bin/bash

# Makefile für das Kernelmodul Caesar Cipher


# Ziel-Modulname
obj-m += caesar.o

# Pfade für das Kernel-Build-System
KERNELDIR ?= /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

# Compiler-Einstellung für den Kernel
CC := x86_64-linux-gnu-gcc-13

# Standard-Ziel: kompiliert das Kernelmodul
default:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) CC=$(CC) modules

# Ziel zum Aufräumen: löscht erzeugte Dateien
clean:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) clean

# Ziel zum Laden des Moduls
load:
	sudo insmod caesar.ko

# Ziel zum Entladen des Moduls
unload:
	sudo rmmod caesar

# Ziel zum Neuladen des Moduls
reload:	unload load

# Ziel für die Überprüfung des Kernel-Logs
log:
	sudo dmesg | tail

# Ziel zum Überprüfen, ob das Modul geladen ist
lcheck:
	sudo lsmod | grep -q caesar

# Ziel zum Ausgeben der Devices
show:
	sudo ls -l /dev/encrypt /dev/decrypt

# Ziel zum Ausführen eines Encryption-Tests
etest:
	sudo bash -c 'echo "Hello hello!" > /dev/encrypt' | sudo cat /dev/encrypt

# Ziel zum Ausführen eines Decryption-Tests
dtest:
	sudo bash -c 'echo "Khoorckhoor!" > /dev/decrypt' | sudo cat /dev/decrypt

# Ziel zum Zurücksetzen der Puffer für /dev/encrypt und /dev/decrypt
reset:
	sudo dd if=/dev/zero of=/dev/encrypt bs=40 count=1
	sudo dd if=/dev/zero of=/dev/decrypt bs=40 count=1

# Hilfe-Ziel: zeigt die verfügbaren Ziele an
help:
	@echo "Verfügbare Ziele:"
	@echo " make		- Compile and load kernel module"
	@echo " make clean	- Delete module files"
	@echo " make load	- Load kernel module"
	@echo " make unload	- Unload kernel module"
	@echo " make reload	- Reload kernel module"
	@echo " make log	- Show last kernel logs"
	@echo " make lcheck	- Check if kernel module is loaded"
	@echo " make show	- Show device nodes"
	@echo " make etest	- Do encryption test"
	@echo " make dtest	- Do decryption test"
	@echo " make reset	- Reset device buffers"
	@echo " make help	- Show this help"

# Standardziel für make ohne Argumente:
# Kompilieren & Laden des Moduls, Ausgeben des Kernel Logs und Ausgeben verfügbaren Ziele
.PHONY:
	default clean load unload reload log lcheck show etest dtest reset help

