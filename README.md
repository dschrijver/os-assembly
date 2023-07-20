# os-assembly
A simple operating system written in x86-assembly

## Requirements and compiling the OS
- The OS is written for x86 processors (important if you run it on bare metal).
- The [Makefile](Makefile) used to compile the OS is written for Ubuntu, but this file can be changed to compile the OS anywhere.
- Required programs to compile the OS are nasm, make and cat (or any other program used to concatinate files).
- To compile the image, move to the root folder containing the [Makefile](Makefile) and run the command ```make os_image.iso```.

## Running the OS
After os_image.iso is compiled, this image can be either written to a USB using a program such as dd, or an emulator can be used. 

The program Qemu can be used to emulate the OS on Ubuntu. Qemu is installed by: 

```console
foo@bar:~$ sudo apt install qemu-system-i386
```

The operating system can be ran using Qemu by either using ```make run``` after compiling os_image.iso, or by running the command ```make``` to compile and run the OS in one go. 
