[bits 32]

PIC1_COMMAND equ 0x20
PIC1_DATA equ 0x21
PIC2_COMMAND equ 0xA0
PIC2_DATA equ 0xA1
ICW4_8086 equ 0x01 ; 8086/88 (MCS-80/85) mode
PIC_EOI equ 0x20 ; End of Interrupt

%assign C 0 ; counter for the array of strings

; Parameters:
; None
; Returns:
; None
isr_install:
    pushad

    ; Install ISRs. EAX is the offset in the IDT
    mov eax, 0
    mov ebx, isr0
    call set_idt_gate
    mov eax, 1
    mov ebx, isr1
    call set_idt_gate
    mov eax, 2
    mov ebx, isr2
    call set_idt_gate
    mov eax, 3
    mov ebx, isr3
    call set_idt_gate
    mov eax, 4
    mov ebx, isr4
    call set_idt_gate
    mov eax, 5
    mov ebx, isr5
    call set_idt_gate
    mov eax, 6
    mov ebx, isr6
    call set_idt_gate
    mov eax, 7
    mov ebx, isr7
    call set_idt_gate
    mov eax, 8
    mov ebx, isr8
    call set_idt_gate
    mov eax, 9
    mov ebx, isr9
    call set_idt_gate
    mov eax, 10
    mov ebx, isr10
    call set_idt_gate
    mov eax, 11
    mov ebx, isr11
    call set_idt_gate
    mov eax, 12
    mov ebx, isr12
    call set_idt_gate
    mov eax, 13
    mov ebx, isr13
    call set_idt_gate
    mov eax, 14
    mov ebx, isr14
    call set_idt_gate
    mov eax, 15
    mov ebx, isr15
    call set_idt_gate
    mov eax, 16
    mov ebx, isr16
    call set_idt_gate
    mov eax, 17
    mov ebx, isr17
    call set_idt_gate
    mov eax, 18
    mov ebx, isr18
    call set_idt_gate
    mov eax, 19
    mov ebx, isr19
    call set_idt_gate
    mov eax, 20
    mov ebx, isr20
    call set_idt_gate
    mov eax, 21
    mov ebx, isr21
    call set_idt_gate
    mov eax, 22
    mov ebx, isr22
    call set_idt_gate
    mov eax, 23
    mov ebx, isr23
    call set_idt_gate
    mov eax, 24
    mov ebx, isr24
    call set_idt_gate
    mov eax, 25
    mov ebx, isr25
    call set_idt_gate
    mov eax, 26
    mov ebx, isr26
    call set_idt_gate
    mov eax, 27
    mov ebx, isr27
    call set_idt_gate
    mov eax, 28
    mov ebx, isr28
    call set_idt_gate
    mov eax, 29
    mov ebx, isr29
    call set_idt_gate
    mov eax, 30
    mov ebx, isr30
    call set_idt_gate
    mov eax, 31
    mov ebx, isr31
    call set_idt_gate

    ; Remap PIC
    ; Store masks
    mov dx, word PIC1_DATA
    in al, dx
    mov bl, al
    mov dx, word PIC1_DATA
    in al, dx
    mov bh, al

    ; Start initialization sequence
    mov dx, word PIC1_COMMAND
    mov al, 0x11
    out dx, al
    mov dx, word PIC2_COMMAND
    out dx, al

    ; Set the offsets in the IDT
    mov dx, word PIC1_DATA
    mov al, 0x20
    out dx, al
    mov dx, word PIC2_DATA
    mov al, 0x28
    out dx, al

    ; Tell master on which port the slave will be, 4 for IRQ 2
    ; Tell the slave it is on IRQ 2
    mov dx, word PIC1_DATA
    mov al, 4
    out dx, al
    mov dx, word PIC2_DATA
    mov al, 2
    out dx, al

    ; Set environment
    mov dx, word PIC1_DATA
    mov al, byte ICW4_8086
    out dx, al
    mov dx, PIC2_DATA
    out dx, al

    ; Restore mask
    mov dx, word PIC1_DATA
    mov al, bl
    out dx, al
    mov dx, word PIC2_DATA
    mov al, bh
    out dx, al

    ; Install IRQs
    mov eax, 32
    mov ebx, irq0
    call set_idt_gate
    mov eax, 33
    mov ebx, irq1
    call set_idt_gate
    mov eax, 34
    mov ebx, irq2
    call set_idt_gate
    mov eax, 35
    mov ebx, irq3
    call set_idt_gate
    mov eax, 36
    mov ebx, irq4
    call set_idt_gate
    mov eax, 37
    mov ebx, irq5
    call set_idt_gate
    mov eax, 38
    mov ebx, irq6
    call set_idt_gate
    mov eax, 39
    mov ebx, irq7
    call set_idt_gate
    mov eax, 40
    mov ebx, irq8
    call set_idt_gate
    mov eax, 41
    mov ebx, irq9
    call set_idt_gate
    mov eax, 42
    mov ebx, irq10
    call set_idt_gate
    mov eax, 43
    mov ebx, irq11
    call set_idt_gate
    mov eax, 44
    mov ebx, irq12
    call set_idt_gate
    mov eax, 45
    mov ebx, irq13
    call set_idt_gate
    mov eax, 46
    mov ebx, irq14
    call set_idt_gate
    mov eax, 47
    mov ebx, irq15
    call set_idt_gate
    
    popad
    ret

; Called by interrupts. 
; Parameters:
; On stack, pushed by interrupt
; Returns:
; None
isr_handler:
    ; The interrupt that calls this function restores the registers

    mov edx, [esp + 40] ; the interrupt number is at the 40 byte position in the stack
    mov ecx, [esp + 44] ; error code position in the stack, is pushed sooner.
    mov eax, IML ; eax is equal to the length of a message
    mul edx ; multiply eax with edx, so interrupt number times the length of a message
    mov ebx, eax ; store it again in ebx
    add ebx, IMSG + KERNEL_OFFSET ; complete address to the message
    call print

    ret

; Called by IRQs. 
; Parameters:
; On stack, pushed by interrupt
; Returns:
; None
irq_handler:
    ; The IRQ that calls this function restores the registers

    ; End of interrupt commands to both master and slave.
    ; Slave only necessary for interrupts coming from slave, 
    ; but will do them both all the time.
    mov dx, word PIC1_COMMAND
    mov al, byte PIC_EOI
    out dx, al
    mov dx, word PIC2_COMMAND
    out dx, al

    mov edx, dword [esp + 40] ; the interrupt number is at the 40 byte position in the stack
    mov ebx, dword [esp + 44] ; the IRQ number position in the stack, is pushed sooner.
    
    cmp ebx, 0 ; PIT interrupt
    je .timer
    
    cmp ebx, 1 ; check if it is a keyboard interrupt
    je .keyboard

    .timer:
        call timer
        jmp .end

    .keyboard:
        call keyboard
        jmp .end

    .end:
    ret


IMSG: ; Interrupt messages array
    db "Division By Zero", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Debug", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Non Maskable Interrupt", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Breakpoint", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Into Detected Overflow", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Out of Bounds", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Invalid Opcode", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "No Coprocessor", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)

    db "Double Fault", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Coprocessor Segment Overrun", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Bad TSS", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Segment Not Present", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Stack Fault", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "General Protection Fault", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Page Fault", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Unknown Interrupt", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)

    db "Coprocessor Fault", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Alignment Check", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Machine Check", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Reserved", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Reserved", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Reserved", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Reserved", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Reserved", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)

    db "Reserved", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Reserved", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Reserved", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Reserved", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Reserved", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Reserved", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Reserved", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)
    db "Reserved", 0
    times IML - ($ - IMSG - C*IML) db 0
    %assign C (C + 1)