#!/bin/bash

# Makefile für das Kernelmodul Caesar Cipher

# Modulname
MODULE_NAME = caesar

# Ziel-Modulname
obj-m += $(MODULE_NAME).o

# Pfade
KERNEL ?= /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

# Compiler-Version
CC := x86_64-linux-gnu-gcc-13

# Standardwert für Caesar-Verschiebung
SHIFT ?= 3

# Standard-Ziel: kompiliert das Kernelmodul
default:
	$(MAKE) -C $(KERNEL) M=$(PWD) CC=$(CC) modules

# Ziel zum Aufräumen: löscht erzeugte Dateien
clean:
	$(MAKE) -C $(KERNEL) M=$(PWD) clean

# Ziel zum Laden des Moduls
load:
	sudo insmod $(MODULE_NAME).ko

# Ziel zum Entladen des Moduls
unload:
	sudo rmmod $(MODULE_NAME)

# Ziel zum Neuladen des Moduls
reload:	unload load

# Ziel für die Überprüfung des Kernel-Logs
log:
	sudo dmesg | tail

# Ziel zum Überprüfen, ob das Modul geladen ist
lcheck:
	sudo lsmod | grep -q $(MODULE_NAME)

# Ziel zum Ausgeben der Geräte und Puffer
pdev:
	sudo ls -l /dev/encrypt /dev/decrypt
	sudo cat /dev/encrypt
	sudo cat /dev/decrypt

# Ziel zum Setzen des shift Parameters zur Laufzeit
shift:
	sudo echo $(SHIFT) | sudo tee /sys/module/$(MODULE_NAME)/parameters/shift

# Ziel zum Ausgeben des shift Parameters
pshift:
	sudo cat /sys/module/$(MODULE_NAME)/parameters/shift

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
	@echo " make pdev	- Print devices and buffers"
	@echo " make shift	- Set shift parameter for caesar cipher"
	@echo " make pshift	- Print shift parameter"
	@echo " make etest	- Do encryption test"
	@echo " make dtest	- Do decryption test"
	@echo " make reset	- Reset device buffers"
	@echo " make help	- Print this help"

# Alle Ziele
.PHONY:
	default clean load unload reload log lcheck pdev shift pshift etest dtest reset help

