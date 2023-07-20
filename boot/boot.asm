[bits 16] ; for correct NASM compiling
; [org 0x7c00]
; this time ds is set to 0x7c0 instead, because I hate myself

; constants
BOOT_OFFSET equ 0x7c00
KERNEL_OFFSET equ 0x1000 ; load kernel to this absolute memory address
STACK_BASE_16BIT equ 0x8000

  ; code

    mov bx, BOOT_OFFSET >> 4 ; division by 16
    mov ds, bx ; for the offset
    mov bx, 0 
    mov es, bx ; to make sure this offset is zero

    mov byte [BOOT_DISK_NUMBER], dl ; boot disk number automatically saved
    ; in dl, store it in BOOT_DISK_NUMBER

    ; setting up stack
    mov bp, STACK_BASE_16BIT ; bottom of stack, at the top of the free space
    mov sp, bp ; top of stack at same position, grows downwards

    ; 16bit message
    mov bx, MSG_16BIT ; store address of string here
    call print ; ds is set correct

    ; load the kernel
    mov bx, KERNEL_OFFSET ; data is loaded to es:bx = 0x9000
    mov dh, 16 ; amount of sectors (of 512 bytes) to read 
    mov dl, byte [BOOT_DISK_NUMBER] ; to be sure dl is right
    call disk_load

    jmp switch_to_32bit ; after the switch, it jumps back
    ; to the switch_to_kernel function


; 16 bit files
%include "boot/print.asm"
%include "boot/disk_load.asm"
%include "boot/gdt.asm"
; 32 bit files
%include "boot/switch_to_32bit.asm"
%include "boot/print_32bit.asm"

[bits 32]
switch_to_kernel:
    mov ebx, MSG_32BIT + BOOT_OFFSET ; offset by position boot sector
    call print_32bit

    mov bx, KERNEL_OFFSET
    jmp bx ; this makes the jump a far jump. Otherwise a relative jump 
    ; is done, offset by 0x7c00. 
  
; storage
TEST_MSG:
    db "test", 0 
MSG_32BIT:
    db "Entered 32 bit protected mode", 0

MSG_16BIT:
    db "Entered 16 bit mode", 0

BOOT_DISK_NUMBER:
    db 0

DISK_LOAD_ERROR_MSG:
    db "Error when loading from disk", 0

; padding
times 510 - ($ - $$) db 0
; magic number
dw 0xaa55