[bits 32]

ISR_AMOUNT equ 32 ; amount of interrupt service routines in IDT
IRQ_AMOUNT equ 16
IML equ 30 ; Interrupt Message Length Max


idt:
    times (ISR_AMOUNT + IRQ_AMOUNT) dq 0

    idt.end:

idt_register:
    dw idt.end - idt - 1; size, first 16 bits, one less than idt actual size
    dd idt + KERNEL_OFFSET ; offset, last 32 bits, incluse kernel offset

; Parameters:
; EAX: Position in the IDT
; EBX: Pointer to ISR
; Returns:
; None
set_idt_gate:
    pushad
    ; ecx is the counter n, position in IDT
    ; ebx is the label of the ISR
    add ebx, KERNEL_OFFSET
    mov ecx, 8
    mul ecx ; eax is multiplied by 8
    ; so eax now contains the offset in the idt
    add eax, idt + KERNEL_OFFSET ; eax is absolute offset IDT gate
    mov [eax], word bx ; Lower two bytes of pointer to ISR
    add eax, 2
    mov [eax], word 0x08 ; IDT settings
    add eax, 2
    mov [eax], byte 0x0 ; IDT settings
    inc eax
    mov [eax], byte 0x8e ; IDT settings
    inc eax
    shr ebx, 16
    mov [eax], word bx ; Higher two bytes of pointer to ISR

    popad
    ret