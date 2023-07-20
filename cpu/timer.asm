[bits 32]

PIT_COMMAND equ 0x43 ; Mode/Command register, write only
PIT_DATA equ 0x40 ; Channel 0 data port (read/write)
OSCILLATOR_FREQUENCY equ 1193182

; Parameters:
; EBX: frequency
; Returns:
; None
init_timer:
    ; The minimum frequency is 18 HZ. 
    pushad
    push ebx ; store the desired frequency on the stack

    mov eax, dword OSCILLATOR_FREQUENCY
    mov edx, 0 ; For division, EDX:EAX is divided.
    div ebx ; EAX will be the divisor, remainder in EDX
    ; divisor = 1193182 / requested frequency
    mov ecx, eax ; Store the divisor in ecx

    mov dx, word PIT_COMMAND
    mov al, 00110100b ; Channel 0, Access mode low/high, rate generator, 16-bit
    out dx, al

    ; Lowest bits followed by the highest bits in the data port. 
    ; Load the divisor onto the PIT
    mov dx, word PIT_DATA
    mov al, cl
    out dx, al ; Lowest bits
    mov al, ch
    out dx, al ; Highest bits

    ; store the new frequency
    mov word [FREQUENCY + KERNEL_OFFSET], bx

    ; Success message
    mov ebx, PIT_MESSAGE + KERNEL_OFFSET
    call print

    pop ebx ; Restore the desired frequency from the stack
    call print_decimal
    mov ebx, PIT_MESSAGE_2 + KERNEL_OFFSET
    call print

    popad
    ret


; This function is called by the PIT on IRQ 0
; Parameters:
; None
; Returns:
; None
timer: 
    pushad

    ; Increase ticks
    mov ecx, dword [TICKS + KERNEL_OFFSET]
    inc ecx

    ; Sleep function
    mov ebx, dword [SLEEP_TICKS + KERNEL_OFFSET]
    test ebx, ebx
    jz .clock
    dec ebx
    mov dword [SLEEP_TICKS + KERNEL_OFFSET], ebx

    ; Clock
    .clock:
    mov dword [TICKS + KERNEL_OFFSET], ecx

    mov eax, ecx
    mov edx, 0
    mov ecx, 0
    mov cx, word [FREQUENCY + KERNEL_OFFSET]
    div ecx

    cmp edx, 0
    je .time
    jmp .end

    .time:
        call clock
    .end:

    popad
    ret


; Called by the timer function every second, to update the time displayed on screen
; Parameters:
; EAX: time to print, in seconds
; Returns: 
; None
clock:
    pushad

    mov ecx, 0 ; position where to print
    mov ebx, eax ; store time to print in ebx

    ; Store the cursor position 
    call get_cursor ; ax becomes the cursor position
    mov edx, 0
    mov dx, ax
    push edx

    call kprint_decimal

    ; Restore the cursor position
    pop ebx
    call set_cursor

    popad
    ret


; Parameters:
; EBX: time in milliseconds
; Returns:
; None
sleep:
    pushad

    mov eax, 0
    mov ax, word [FREQUENCY + KERNEL_OFFSET]
    mul ebx

    mov edx, 0 ; for division
    mov ecx, 0
    mov cx, word [NUMBER + KERNEL_OFFSET]
    ; why does this not work?!
    ; mov ecx, 1000
    div ecx

    mov dword [SLEEP_TICKS + KERNEL_OFFSET], eax

    ; wait for the time to have ticked
    .loop:
        mov ecx, dword [SLEEP_TICKS + KERNEL_OFFSET]
        cmp ecx, 0
        je .end
        jmp .loop

    .end:
    popad
    ret


PIT_MESSAGE:
    db "The new clock frequency will be: ", 0

PIT_MESSAGE_2:
    db "Hz", 0

TICKS:
    dd 0

FREQUENCY:
    dw 0

SLEEP_TICKS:
    dd 0

NUMBER: ; For the division by 1000. 
    dw 1000