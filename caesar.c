/**
 * @file	caesar.c
 * @author	Adrian Morgenthal
 * @date	18.06.2024
 * @version	1.0
 * @brief	This Linux kernel module implements two devices:
 * /dev/encrypt (Minor Number 0): Encrypts text using a Caesar cipher.
 * /dev/decrypt (Minor Number 1): Decrypts text encrypted with the same cipher.
 * Features:
 * - Supports custom shift amount via translate_shift module parameter
 * - Handles non-alphabet characters without modification
 * - Uses 40-character buffers for each device
 * @see www.github.com/amaldoror 
*/

#include <linux/init.h>		// Macros für Initialisierungs- und Bereinigungsfunktionen
#include <linux/module.h>	// Grundlegende Moduleheader
#include <linux/kernel.h>	// Kernel-Funktionen und -Typen
#include <linux/fs.h>		// Dateisystemoperationen
#include <linux/uaccess.h>	// Kopieren von Daten zwischen Kernel- und User-Space
#include <linux/mutex.h>	// Mutex-Funktionen

#define DEVICE_NAME "caesar_cipher"
#define BUFFER_SIZE 40
#define ALPHABET "ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz"
#define ALPHABET_SIZE 53

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Adrian Morgenthal");
MODULE_DESCRIPTION("Caesar cipher device driver");
MODULE_VERSION("1.0");

// Modulparameter für die Verschiebung
static int translate_shift = 3;
module_param(translate_shift, int, S_IRUGO);
MODULE_PARM_DESC(translate_shift, "The number of characters to shift (default is 3)");

// Puffer und zugehörige Größen für die Geräte /dev/encrypt und /dev/decrypt
static char encrypt_buffer[BUFFER_SIZE];
static char decrypt_buffer[BUFFER_SIZE];
static int encrypt_size = 0;
static int decrypt_size = 0;

// Mutexes zur Sicherstellung der exklusiven Nutzung der Geräte
static struct mutex encrypt_mutex;
static struct mutex decrypt_mutex;

// Major Number
static int major;

// Funktionsprototypen
static int device_open(struct inode *, struct file *);
static int device_release(struct inode *, struct file *);
static ssize_t device_read(struct file *, char *, size_t, loff_t *);
static ssize_t device_write(struct file *, const char *, size_t, loff_t *);
//static void caesar_cipher(char *input, char *output, int shift, int size);

// Dateisystemoperationen
static struct file_operations fops = {
	.open = device_open,
	.read = device_read,
	.write = device_write,
	.release = device_release,
};

// Initialisierungsfunktion des Moduls
static int __init caesar_init(void){
	// Registrierung des Zeichengeräts
	major = register_chrdev(0, DEVICE_NAME, &fops);
	if (major < 0){
		printk(KERN_ALERT "CaesarCipher failed to register a major number\n");
		return major;
	}
	printk(KERN_INFO "CaesarCipher: registered correctly with major number %d\n", major);

	// Initialisierung der Mutexes
	mutex_init(&encrypt_mutex);
	mutex_init(&decrypt_mutex);

	return 0;
}

// Bereinigungsfunktion des Moduls
static void __exit caesar_exit(void){
	// Deregistrierung des Zeichengeräts
	unregister_chrdev(major, DEVICE_NAME);
	printk(KERN_INFO "CaesarCipher: unregistered correctly\n");
}

// Öffnen der Gerätedatei
static int device_open(struct inode *inodep, struct file *filep){
	int minor = iminor(inodep); // Abrufen der Minor-Nummer
	// Überprüfen und Sperren des entsprechenden Mutex
	if (minor == 0) {
		if (!mutex_trylock(&encrypt_mutex)) {
			printk(KERN_ALERT "CaesarCipher: Device /dev/encrypt is in use by another process\n");
			return -EBUSY;
		}
	} else if (minor == 1) {
		if (!mutex_trylock(&decrypt_mutex)) {
			printk(KERN_ALERT "CaesarCipher: Device /dev/decrypt is in use by another process\n");
			return -EBUSY;
		}
	}
	printk(KERN_INFO "CaesarCipher: Device has been opened\n");
	return 0;
}

// Schließen der Gerätedatei
static int device_release(struct inode *inodep, struct file *filep){
	int minor = iminor(inodep); // Abrufen der Minor-Nummer
	// Entsperren des entsprechenden Mutex
	if (minor == 0) {
		mutex_unlock(&encrypt_mutex);
	} else if (minor == 1) {
		mutex_unlock(&decrypt_mutex);
	}
	printk(KERN_INFO "CaesarCipher: Device successfully closed\n");
	return 0;
}

// Lesen aus der Gerätedatei
static ssize_t device_read(struct file *filep, char *buffer, size_t len, loff_t *offset){
	int minor = iminor(filep->f_inode); // Abrufen der Minor-Nummer
	int error_count = 0;

	// Lesen aus dem entsprechenden Puffer basierend auf der Minor-Nummer
	if (minor == 0) {
		if (*offset >= encrypt_size) return 0;
		if (len > encrypt_size - *offset) len = encrypt_size - *offset;
		error_count = copy_to_user(buffer, encrypt_buffer + *offset, len);
	} else if (minor == 1) {
		if (*offset >= decrypt_size) return 0; 
		if (len > decrypt_size - *offset) len = decrypt_size - *offset;
		error_count = copy_to_user(buffer, decrypt_buffer + *offset, len);
	}
	if (error_count == 0) {
		*offset += len;
		return len;
	} else {
		printk(KERN_INFO "CaesarCipher: Failed to send %d characters to the user\n", error_count);
		return -EFAULT;
	}
}

// Funktion zur Durchführung der Cäsar-Verschlüsselung/-Entschlüsselung
static void caesar_cipher(char *input, char *output, int shift, int size) {
	int i, j;
	for (i = 0; i < size; i++) {
		char c = input[i];
		const char *p = strchr(ALPHABET, c); // Suchen des Zeichens im Alphabet
		if (p) {
			j = (p - ALPHABET + shift) % ALPHABET_SIZE; // Verschiebung berechnen
			if (j < 0) j += ALPHABET_SIZE; // Sicherstellen, dass der Index positiv ist
			output[i] = ALPHABET[j]; // Verschobenes Zeichen speichern
		} else {
			output[i] = c; // Nicht im Alphabet enthaltene Zeichen unverändert übernehmen
		}
	}
}

// Schreiben in die Gerätedatei
static ssize_t device_write(struct file *filep, const char *buffer, size_t len, loff_t *offset){
	int minor = iminor(filep->f_inode); // Abrufen der Minor-Nummer
	int error_count = 0;

	if (len > BUFFER_SIZE) len = BUFFER_SIZE; // Begrenzung der Eingabelänge auf die Puffergröße

	// Verschlüsselung oder Entschlüsselung basierend auf der Minor-Nummer
	if (minor == 0) {
		error_count = copy_from_user(encrypt_buffer, buffer, len);
		if (error_count != 0) {
			printk(KERN_INFO "CaesarCipher: Failed to receive %d characters from the user\n", error_count);
		}
		caesar_cipher(encrypt_buffer, encrypt_buffer, translate_shift, len);
		encrypt_size = len;
	} else if (minor == 1) {
		error_count = copy_from_user(decrypt_buffer, buffer, len);
		if (error_count != 0) {
			printk(KERN_INFO "CaesarCipher: Failed to receive %d characters from the user\n", error_count);
		}
		caesar_cipher(decrypt_buffer, decrypt_buffer, -translate_shift, len);
		decrypt_size = len;
	}
	return len;
}

// Modulinitialisierungs- und Bereinigungsfunktionen registrieren
module_init(caesar_init);
module_exit(caesar_exit);
