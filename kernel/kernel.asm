[bits 32]

KERNEL_OFFSET equ 0x1000
CODE_SEGMENT equ 0x08


kernel_entry: 
    call main
    jmp $
main:
    call clear_black
    call newline
    mov ebx, MESSAGE + KERNEL_OFFSET
    call print
    call isr_install

    ; set the IDT
    lidt [idt_register + KERNEL_OFFSET]

    sti ; turn on hardware interrupts. 
    
    ; set the PIT frequency
    mov ebx, 100 ; The minimum frequency is 18 HZ. 
    call init_timer
    call newline

    fninit ; Load defaults to FPU

    mov ebx, 100 ; Wait a 0.1 seconds for randomizer initialization
    call sleep

    ; Initialize randomizer. Not completely necessary.
    mov ebx, dword [TICKS + KERNEL_OFFSET]
    call srand

    mov ebx, KEY_FUNCTIONS + KERNEL_OFFSET
    call print

    .home:
        mov bl, byte [RUNNING + KERNEL_OFFSET] ; Toggled by F4
        test bl, bl
        jnz .start_game_rc
        jmp .end
        .start_game_rc:
            call start_game_rc
        .end:
        jmp .home

    ret ; goes back to kernel_entry to do absolutely nothing

%include "drivers/screen.asm"
%include "drivers/keyboard.asm"
%include "cpu/idt.asm"
%include "cpu/isr.asm"
%include "cpu/interrupt.asm"
%include "cpu/timer.asm"
%include "kernel/math.asm"
%include "game/game.asm"


MESSAGE: 
    db "Entered kernel. ", 0

KEY_FUNCTIONS:
    db "[ESC]: clear screen, [F1]: disable cursor, [F2]: enable cursor, [F3]: toggle drawing mode (spacebar), [F4]: toggle game",0