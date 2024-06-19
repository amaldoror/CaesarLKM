#!/bin/bash

# Makefile für das Kernelmodul Caesar Cipher

# Modulname
MODULE = caesar

# Ziel-Modulname
obj-m += $(MODULE).o

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
	@if sudo lsmod | sudo grep -q $(MODULE); then \
		echo "$(MODULE) is already loaded"; \
	else \
		sudo insmod $(MODULE).ko; \
		echo "$(MODULE) loaded"; \
	fi

# Ziel zum Entladen des Moduls
unload:
	@if sudo lsmod | sudo grep -q $(MODULE); then \
		sudo rmmod $(MODULE); \
		echo "$(MODULE) unloaded"; \
	else \
		"$(MODULE)"; \
	fi

# Ziel zum Neuladen des Moduls
reload:	unload load

# Ziel für die Überprüfung des Kernel-Logs
log:
	@sudo dmesg | tail

# Ziel zum Überprüfen, ob das Modul geladen ist
lcheck:
	@if sudo lsmod | sudo grep -q $(MODULE); then \
		echo "$(MODULE) is loaded"; \
	else \
		echo "$(MODULE) is not loaded"; \
	fi

# Ziel zum Ausgeben der Geräte und Puffer
pdev:
	@sudo ls -l /dev/encrypt /dev/decrypt
	@echo ""
	@sudo cat /dev/encrypt
	@echo ""
	@sudo cat /dev/decrypt
	@echo ""

# Ziel zum Setzen des shift Parameters zur Laufzeit
#sudo echo $(SHIFT) | sudo tee /sys/module/$(MODULE)/parameters/shift
shift:
	@sudo echo "SHIFT=$(SHIFT)"
	@sudo sh -c 'echo $(SHIFT) > /sys/module/$(MODULE)/parameters/shift'

# Ziel zum Ausgeben des shift Parameters
pshift:
	@sudo cat /sys/module/$(MODULE)/parameters/shift

# Ziel zum Ausführen eines Encryption-Tests
etest:
	@sudo bash -c 'echo "Hello hello!" > /dev/encrypt'
	@echo "Encryption:"
	@sudo cat /dev/encrypt

# Ziel zum Ausführen eines Decryption-Tests
dtest:
	@sudo bash -c 'echo "Khoorckhoor!" > /dev/decrypt'
	@echo "Decryption:"
	@sudo cat /dev/decrypt

# Ziel zum Zurücksetzen der Puffer für /dev/encrypt und /dev/decrypt
reset:
	@sudo dd if=/dev/zero of=/dev/encrypt bs=40 count=1
	@sudo dd if=/dev/zero of=/dev/decrypt bs=40 count=1
	@echo "$(MODULE) device buffers reset"

# Hilfe-Ziel: zeigt die verfügbaren Ziele an
help:
	@echo "Verfügbare Ziele:"
	@echo " 1. make		- Compile and load kernel module"
	@echo " 2. make clean		- Delete module files"
	@echo " 3. make load		- Load kernel module"
	@echo " 4. make unload		- Unload kernel module"
	@echo " 5. make reload		- Reload kernel module"
	@echo " 6. make log		- Show last kernel logs"
	@echo " 7. make lcheck		- Check if kernel module is loaded"
	@echo " 8. make pdev		- Print devices and buffers"
	@echo " 9. make shift		- Set shift parameter for caesar cipher"
	@echo "10. make pshift		- Print shift parameter"
	@echo "11. make etest		- Do encryption test"
	@echo "12. make dtest		- Do decryption test"
	@echo "13. make reset		- Reset device buffers"
	@echo "14. make help		- Print this help"

# Alle Ziele
.PHONY:
	default clean load unload reload log lcheck pdev shift pshift etest dtest reset help

