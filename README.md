
# CaesarLKM

### Linux Kernel Module for Caesar Cipher


## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Makefile](#makefile)
- [Usage](#usage)
- [Module Parameters](#module-parameters)
- [File Operations](#file-operations)
- [Security Considerations](#security-considerations)
- [License](#license)
- [Authors](#authors)

## Introduction

Caesar cipher is a basic substitution cipher where each character in the plaintext is shifted by a certain number of positions in the alphabet. In this driver, we use the English alphabet including spaces, totaling 53 characters.

The kernel module allows dynamic encryption and decryption of text accessed through the <code>/dev/encrypt</code> and <code>/dev/decrypt</code> device files.

## Prerequisites

- Linux operating system (tested on Ubuntu 24.04 LTS)
- Basic knowledge of using kernel modules and device files in Linux

## Installation

1. **Clone the repository:**
   <code>git clone https://github.com/amaldoror/CaesarLKM
   cd CaesarLKM</code>
   
2. **Install libraries:**
   <code>sudo apt-get update
   apt-cache search linux-headers-$(uname -r)
   sudo apt-get install linux-headers-[VERSION]   </code>

## Makefile

1. **Compile the Kernel Module:**
   <code>make</code>
   
2. **Clean up:**
   <code>make clean</code>

3. **Load the Kernel Module:**
   <code>make load</code>
   
4. **Unload the Kernel Module:**
   <code>make unload</code>
   
5. **View Kernel Logs:**
   <code>make log</code>
   
6. **Help:**
   <code>make help</code>

## Usage

To use the module, it has to be compiled and loaded.
Once the module is loaded, the device files <code>/dev/encrypt</code> and <code>/dev/decrypt</code> are available.

1. **Encryption:**
   <code>echo "Hello hello!" > /dev/encrypt
    cat /dev/encrypt  # Outputs "Khoor khoor!"</code>
    
2. **Decryption:**
   <code>    echo "Khoor khoor!" > /dev/decrypt
    cat /dev/decrypt  # Outputs "Hello hello!"</code>
    
## Module Parameters

The module supports the translate_shift parameter to specify the number of characters to shift for encryption. By default, this is set to 3.

Example of loading the module with a different shift value:

   <code>sudo insmod caesar_cipher.ko translate_shift=5</code>
   
## File Operations

The module implements the following file operations for the device files:

   - open: Opens the device file and locks the corresponding mutex.
   - release: Closes the device file and unlocks the mutex.
   - read: Reads from the device file and copies data to user space.
   - write: Writes to the device file and performs Caesar cipher encryption or decryption.

## Security Considerations

The driver uses mutexes to ensure that only one process can access the device files at a time. It's recommended to encrypt only ASCII characters that are part of the defined alphabet (ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz). Non-included characters are passed through unchanged.
   
## License

This project is licensed under the GNU General Public License (GPL) v2. For more details, see the LICENSE file.

## Authors

Adrian Morgenthal
<url>www.github.com/amaldoror</url>


