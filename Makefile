# Makefile für das Kernelmodul Caesar Cipher

# Ziel-Modulname
obj-m += caesar.o

# Pfade für das Kernel-Build-System
KERNELDIR ?= /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

# Standard-Ziel: kompiliert das Kernelmodul
default:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules

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

# Hilfe-Ziel: zeigt die verfügbaren Ziele an
help:
	@echo "Verfügbare Ziele:"
	@echo " make		- Kompiliert das Kernelmodul"
	@echo " make clean	- Löscht erzeugte Dateien"
	@echo " make load	- Lädt das Kernelmodul"
	@echo " make unload	- Entlädt das Kernelmodul"
	@echo " make log	- Zeigt die letzten Kernel-Logs (dmesg)"
	@echo " make help	- Zeigt diese Hilfe"

# Standardziel für make ohne Argumente: Kompilieren des Moduls
.PHONY: default clean load unload log help
