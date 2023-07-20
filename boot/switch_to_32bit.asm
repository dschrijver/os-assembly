[bits 16] ; to be sure NASM compiles it right

CODE_SEGMENT equ 0x08 ; address in GDT
DATA_SEGMENT equ 0x10 ; address in GDT
STACK_BASE_32BIT equ 0x90000 

switch_to_32bit:
    cli ; disable interrupts
    lgdt [gdtr] ; fill the GDTR register to load GDT
    ; gdtr register contains limit and base of GDT
    mov eax, cr0 
    or al, 1 
    mov cr0, eax ; Protection Enable bit is set in Control Register 0
    ; This makes the actual switch to 32bit Protected Mode
    jmp CODE_SEGMENT:complete_flush + 0x7c00
    ; stages of the CPU cycle are processed in parallel, called pipelining
    ; some can still be in process, so a farr jump flushes all these 
    ; instructions. Far jump is a jump to another segment.
    ; This also loads CS with the right value (0x08) in the GDT.
    ; the label has to be offset because it is a far jump, otherwise 
    ; a relative jump is done by just subtracting or adding from current
    ; address.

[bits 32] ; in 32 bit mode starting from here.
complete_flush:
    mov ax, DATA_SEGMENT
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax ; update all registers apart from cs with 
    ; the data segment position in the GDT
    mov ebp, STACK_BASE_32BIT ; move stack base to top of free space in memory
    mov esp, ebp 

    jmp switch_to_kernel