[bits 32]

; Second time defined
MAX_COLS equ 80

keyboard:
    pushad
    mov dx, 0x60 ; This is where the scancode is saved by the PIC

    mov eax, 0
    in al, dx ; scancode


    ; Special keys
    cmp eax, 1 ; Escape
    je .escape
    cmp eax, 14 ; Backspace
    je .backspace 
    cmp eax, 28 ; Enter
    je .enter
    ; The spacebar has two modes, for typing and for making cells
    cmp eax, 57 ; Spacebar
    je .check_init_mode
    ; F keys
    cmp eax, 59 ; F1
    je .disable
    cmp eax, 60 ; F2
    je .enable
    cmp eax, 61 ; F3
    je .toggle_init_mode
    cmp eax, 62 ; F4
    je .toggle_game

    ; Arrow keys
    cmp eax, 72
    je .uarrow
    cmp eax, 75
    je .larrow
    cmp eax, 77
    je .rarrow
    cmp eax, 80
    je .darrow    

    ; Normal keys
    cmp eax, 70 ; If the scancode is bigger than this, it is not defined in the character table
    jg .end
    
    .character:
        add eax, CHARACTER_DICTIONARY + KERNEL_OFFSET
        mov bl, byte [eax]
        call cprint
        jmp .end
    
    ; Special key functions
    .escape:
        call clear_black
        jmp .end
    .backspace:
        call backspace
        jmp .end
    .enter:
        call newline
        jmp .end
    ; Spacebar functions
    .check_init_mode:
        mov bl, byte [INIT_MODE + KERNEL_OFFSET]
        test bl, bl
        jz .character
    .change_cell:
        call get_cursor
        mov ebx, 0
        mov bx, ax
        call alive
        test al, al
        jnz .del_init
        ; Alive
        call create_cell
        jmp .end
        ; Dead
        .del_init:
        call kill_cell
        jmp .end
    ; F key functions
    .disable:
        call disable_cursor
        jmp .end
    .enable:
        call enable_cursor
        jmp .end
    .toggle_init_mode:
        mov bl, byte [INIT_MODE + KERNEL_OFFSET]
        mov al, 1
        xor bl, al
        mov byte [INIT_MODE + KERNEL_OFFSET], bl
        jmp .end
    .toggle_game:
        mov bl, byte [RUNNING + KERNEL_OFFSET]
        mov al, 1
        xor bl, al
        mov byte [RUNNING + KERNEL_OFFSET], bl
        jmp .end
    ; Arrow key functions
    .uarrow:
        mov dx, -MAX_COLS
        call move_cursor
        jmp .end
    .larrow:
        mov dx, -1
        call move_cursor
        jmp .end
    .rarrow:
        mov dx, 1
        call move_cursor
        jmp .end
    .darrow:
        mov dx, MAX_COLS
        call move_cursor
        jmp .end
    
    .end:
    popad
    ret


; Parameters:
; EAX: scancode to print
; Returns:
; None
print_scancode:
    mov ebx, eax
    call print_decimal
    mov bl, ':'
    call cprint
    ret


INIT_MODE:
    db 0

CHARACTER_DICTIONARY:
    db 0 ; ERROR, number 0
    db 0 ; ESCAPE
    db "1"
    db "2"
    db "3"
    db "4"
    db "5"
    db "6"
    db "7"
    db "8"
    db "9"
    db "0"
    db "-"
    db "="
    db 0 ; BACKSPACE
    db 0 ; TAB
    db "Q"
    db "W"
    db "E"
    db "R"
    db "T"
    db "Y"
    db "U"
    db "I"
    db "O"
    db "P"
    db "["
    db "]"
    db 0 ; ENTER
    db 0 ; LCtrl
    db "A"
    db "S"
    db "D"
    db "F"
    db "G"
    db "H"
    db "J"
    db "K"
    db "L"
    db 0x3b ; semi colon
    db "'"
    db "`"
    db 0 ; LShift
    db "\"
    db "Z"
    db "X"
    db "C"
    db "V"
    db "B"
    db "N"
    db "M"
    db ","
    db "."
    db "/"
    db 0 ; Rshift
    db "*" ; keypad asterisk
    db 0 ; LAlt
    db " " ; Spc, number 57
    db 0 ; Capslock
    db 0 ; F1
    db 0 ; F2
    db 0 ; F3
    db 0 ; F4
    db 0 ; F5
    db 0 ; F6
    db 0 ; F7
    db 0 ; F8
    db 0 ; F9
    db 0 ; F10
    db 0 ; Numlock
    db 0 ; Scrolllock

    
