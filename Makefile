# -f flag to delete if present
# format=raw to prevent qemu error
# add @ in front of all commands to make them silent

all: clean os_image.iso run

os_image.iso: boot/boot.bin kernel/kernel.bin
	cat $^ > $@

%.bin: %.asm
	nasm $< -f bin -o $@

clean:
	rm -f *.bin *.iso */*.bin

run: 
	qemu-system-i386 -drive file=os_image.iso,format=raw,if=floppy
