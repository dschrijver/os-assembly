[bits 32] ; for registers eax and stuff

VIDEO_MEMORY equ 0xb8000 ; memory location first character
WHITE_ON_BLACK equ 0x0f ; lower byte contains foreground,
; higher byte background
WHITE_ON_WHITE equ 01111111b

MAX_ROWS equ 25
MAX_COLS equ 80
SIZE equ (MAX_ROWS * MAX_COLS)

REG_SCREEN_CTRL equ 0x3d4 ; setting this port to 14 or 15 changes 
REG_SCREEN_DATA equ 0x3d5 ; the contents of this port


; Prints starting at cursor position
; Parameters:
; EBX: pointer to base of string
; Returns:
; None
print:
    pushad ; save state registers
    mov edx, VIDEO_MEMORY ; use this as counter for video memory location

    call get_cursor
    shl ax, 1
    add dx, ax ; ax contains position of cursor

    mov ah, WHITE_ON_BLACK ; colour mode

    .loop:
        mov al, [ebx] ; load character in al
        cmp al, 0
        je .done ; jump to end if message is complete

        ; print to screen
        mov [edx], ax ; lower byte al in 0xb8000, higher byte ah in 0xb8001

        inc ebx ; move one character to the left
        add edx, 2 ; move two bytes to left for character and colour

        jmp .loop

    .done:
        mov ebx, edx
        sub ebx, VIDEO_MEMORY
        shr ebx, 1 ; divide ebx by 2

        call set_cursor

    popad ; restore registers
    ret ; return to caller address


; For printing at specific starting position
; Parameters:
; EBX: pointer to base of string
; ECX: position
; Returns:
; None
kprint:
    pushad

    push ebx ; store base of string to print

    mov ebx, ecx
    call set_cursor

    pop ebx
    call print

    popad
    ret


; Prints decimal at cursor position
; Parameters:
; EBX: integer to print
; Returns:
; None
print_decimal:
    pushad

    mov esi, esp ; save the top of the stack

    mov eax, ebx ; EAX will be the one which is divided by
    mov ecx, 10 ; Divisor, for decimal.

    sub esp, 1
    mov byte [esp], 0 ; end of the string

    .loop:
        mov edx, 0 ; EDX:EAX will be the one divided by
        div ecx ; result in EAX, remainder in EDX

        mov ebx, edx
        add ebx, 48

        sub esp, 1
        mov byte [esp], bl

        test eax, eax
        jnz .loop

    mov ebx, esp
    call print

    mov esp, esi ; restore stack

    popad
    ret


; Prints hexadecimal at cursor position
; Parameters:
; EBX: integer to print
; Returns:
; None
print_hex:
    pushad

    mov esi, esp ; save the top of the stack

    mov eax, ebx ; EAX will be the one which is divided by
    mov ecx, 0x10 ; Divisor, for hexadecimal.

    sub esp, 1
    mov byte [esp], 0 ; end of the string

    .loop:
        mov edx, 0 ; EDX:EAX will be the one divided by
        div ecx ; result in EAX, remainder in EDX

        mov ebx, edx
        cmp ebx, 9
        jg .letter
        ; number:
        add ebx, 48
        jmp .end
        .letter:
        add ebx, 55
        .end:

        sub esp, 1
        mov byte [esp], bl

        test eax, eax
        jnz .loop

    mov ebx, esp
    call print

    mov esp, esi ; restore stack

    popad
    ret


; Prints float in decimal format at cursor position
; Parameters:
; EBX: REAL4
; Returns:
; None
print_real4:
    pushad

    mov edx, ebx ; store ebx
    ; sign
    shr ebx, 31
    jz .positive
    mov bl, '-'
    call cprint
    .positive:
    mov bl, '1'
    call cprint
    mov bl, '.'
    call cprint
    mov ebx, edx
    ; main
    and ebx, 0x7fffff ; get rid of exponent and sign
    call print_decimal
    ; exponent
    mov ebx, edx
    shr ebx, 23
    and ebx, 0xff ; removes sign bit
    sub ebx, 127
    test ebx, ebx
    jz .end
    push ebx
    mov bl, 'x'
    call cprint
    mov bl, '2'
    call cprint
    mov bl, '^'
    call cprint
    pop ebx
    call print_decimal
    .end:

    popad
    ret


; Prints binary at cursor position
; Parameters:
; EBX: integer to print
; Returns:
; None
print_binary:
    pushad

    mov esi, esp ; save the top of the stack

    mov eax, ebx ; EAX will be the one which is divided by
    mov ecx, 2 ; Divisor, for hexadecimal.

    sub esp, 1
    mov byte [esp], 0 ; end of the string

    .loop:
        mov edx, 0 ; EDX:EAX will be the one divided by
        div ecx ; result in EAX, remainder in EDX

        mov ebx, edx
        add ebx, 48
        
        sub esp, 1
        mov byte [esp], bl

        test eax, eax
        jnz .loop

    mov ebx, esp
    call print

    mov esp, esi ; restore stack

    popad
    ret


; For printing decimals at specific starting position
; Parameters:
; EBX: integer to print
; ECX: position
; Returns:
; None
kprint_decimal: 
    pushad

    push ebx ; store base of string to print

    mov ebx, ecx
    call set_cursor

    pop ebx
    call print_decimal

    popad
    ret


; To print a character at the cursor position
; Parameters:
; BL: character to print
; Returns:
; None
cprint:
    pushad ; save state registers

    test bl, bl ; Check if it is a zero byte
    jz .end

    mov edx, VIDEO_MEMORY ; use this as counter for video memory location

    call get_cursor
    shl ax, 1
    add dx, ax ; ax contains position of cursor

    mov ah, WHITE_ON_BLACK ; colour mode
    mov al, bl ; put character in al

    mov [edx], ax ; print character
    add edx, 2 ; move to next spot in video memory

    mov ebx, edx
    sub ebx, VIDEO_MEMORY
    shr ebx, 1 ; divide ebx by 2
    call set_cursor

    .end:
    popad 
    ret


; Parameters: 
; None
; Returns:
; None
backspace:
    pushad

    mov edx, VIDEO_MEMORY ; use this as counter for video memory location

    call get_cursor
    shl ax, 1
    add dx, ax ; ax contains position of cursor

    sub edx, 2 ; move one position back
    mov al, " "
    mov ah, WHITE_ON_BLACK
    mov [edx], ax

    mov ebx, edx
    sub ebx, VIDEO_MEMORY
    shr ebx, 1 ; divide ebx by 2

    call set_cursor

    popad
    ret


; To make the entire screen 'white'
; Parameters: 
; None
; Returns:
; None
clear:
    pushad

    mov ah, WHITE_ON_WHITE
    mov al, ' '
    mov edx, VIDEO_MEMORY

    mov cx, 0
    mov edx, VIDEO_MEMORY

    .loop:
        mov [edx], ax
        add edx, 2
        inc cx
        cmp cx, SIZE
        jl .loop

    ; set cursor to beginning
    mov ebx, 0
    call set_cursor

    popad
    ret


; To make the entire screen black
; Parameters: 
; None
; Returns:
; None
clear_black:
    pushad

    mov ah, WHITE_ON_BLACK
    mov al, ' '
    mov edx, VIDEO_MEMORY

    mov cx, 0
    mov edx, VIDEO_MEMORY

    .loop:
        mov [edx], ax
        add edx, 2
        inc cx
        cmp cx, SIZE
        jl .loop

    ; set cursor to beginning
    mov ebx, 0
    call set_cursor

    popad
    ret


newline:
    pushad

    mov eax, 0
    call get_cursor
    push eax
    mov bx, MAX_COLS
    mov dx, 0
    div bx
    sub bx, dx
    pop eax
    add bx, ax

    call set_cursor

    popad
    ret


; To set the cursor at a given position
; Parameters:
; EBX: cursor position
; Returns:
; None
set_cursor:
    pushad

    ; The data register contains the higher byte of the position
    ; if the control register is set to 0x0e, and the lower byte
    ; if it is 0x0f

    ; ebx is the parameter which is set to the offset

    ; first set the higher byte
    mov dx, REG_SCREEN_CTRL
    mov al, 0x0e
    out dx, al
    mov dx, REG_SCREEN_DATA
    mov al, bh ; the 8 higher bytes
    out dx, al
    ; the then lower byte
    mov dx, REG_SCREEN_CTRL
    mov al, 0x0f
    out dx, al
    mov dx, REG_SCREEN_DATA
    mov al, bl
    out dx, al

    popad
    ret


; Parameters:
; None
; Returns:
; AX: cursor position
get_cursor: 
    push dx ; only variable used

    mov dx, REG_SCREEN_CTRL
    mov al, 0x0e ; now DATA REGISTER contains higher byte
    out dx, al
    mov dx, word REG_SCREEN_DATA
    in al, dx
    mov ah, al 
    ; the then lower byte
    mov dx, REG_SCREEN_CTRL
    mov al, 0x0f
    out dx, al
    mov dx, word REG_SCREEN_DATA
    in al, dx

    pop dx
    ; ax contains the return value
    ret


; Parameters:
; DX: Change in cursor offset
; Returns:
; None
move_cursor:
    pushad
        
    call get_cursor ; ax is now the cursor offset
    add ax, dx ; dx can be negative here, but still works
    mov bx, ax ; bx is the parameter for set_cursor
    
    cmp bx, 0
    jl .underflow
    cmp bx, SIZE
    jge .overflow
    jmp .end

    .underflow:
        add bx, SIZE
        jmp .end
    .overflow:
        sub bx, SIZE
        jmp .end

    .end:
    call set_cursor

    popad
    ret


; Parameters:
; None
; Returns:
; None
disable_cursor:
    pushad

    mov dx, word REG_SCREEN_CTRL
    mov al, 0x0a 
    out dx, al ; now DATA REGISTER contains cursor start register

    mov dx, word REG_SCREEN_DATA
    mov al, 0x20 ; set it to 0b 0010 0000, if 5th bit is set, cursor off
    out dx, al 

    popad 
    ret


; Parameters:
; None
; Returns:
; None
enable_cursor:
    pushad

    mov dx, word REG_SCREEN_CTRL
    mov al, 0x0a 
    out dx, al ; now DATA REGISTER contains cursor start register

    mov dx, word REG_SCREEN_DATA
    in al, dx ; Now al contains 0x0a data

    and al, 0xc0 ; store only highest two bytes, 0xc0 = 0b 1100 0000
    or al, 14 ; start of cursor, stored in lowest 5 bits
    out dx, al

    mov dx, word REG_SCREEN_CTRL
    mov al, 0x0b
    out dx, al ; now DATA REGISTER contains cursor end register

    mov dx, word REG_SCREEN_DATA
    in al, dx ; Now al contains 0x0a data

    and al, 0xe0 ; store only highest three bytes, 0xe0 = 0b 1110 0000
    or al, 15 ; end of cursor, stored in lowest 5 bits
    out dx, al

    popad
    ret


HEX_PREFIX:
    db "0x", 0