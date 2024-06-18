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
	sudo bash -c 'echo "Hello hello!" > /dev/encrypt' | cat /dev/encrypt

# Hilfe-Ziel: zeigt die verfügbaren Ziele an
help:
	@echo "Verfügbare Ziele:"
	@echo " make		- Kompiliert das Kernelmodul"
	@echo " make clean	- Löscht erzeugte Dateien"
	@echo " make load	- Lädt das Kernelmodul"
	@echo " make unload	- Entlädt das Kernelmodul"
	@echo " make log	- Zeigt die letzten Kernel-Logs (dmesg)"
	@echo " make lcheck	- Überprüft, ob das Modul geladen ist"
	@echo " make show	- Zeigt die erstellten Geräte"
	@echo " make etest	- Führt einen Encryption-Test durch"
	@echo " make help	- Zeigt diese Hilfe"

# Standardziel für make ohne Argumente:
# Kompilieren & Laden des Moduls, Ausgeben des Kernel Logs und Ausgeben verfügbaren Ziele
.PHONY:
	default clean load unload log lcheck show etest help

