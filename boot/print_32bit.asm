[bits 32] ; for registers eax and stuff

VIDEO_MEMORY equ 0xb8000 ; memory location first character
WHITE_ON_BLACK equ 0x0f ; lower byte contains foreground,

; higher byte background

; Parameters: 
; EBX: Pointer to base of string

; Returns:
; None
print_32bit:
    ; ebx contains the memory location of the message
    pushad ; save state registers
    mov ah, WHITE_ON_BLACK ; colour mode
    mov edx, VIDEO_MEMORY ; use this as counter for video memory location

.loop:
    mov al, [ebx] ; load character in al
    cmp al, 0
    je .done ; jump to end if message is complete

    ; print to screen
    mov [edx], ax ; lower byte al in 0xb8000, higher byte ah in 0xb8001

    add ebx, 1 ; move one character to the left
    add edx, 2 ; move two bytes to left for character and colour

    jmp .loop

.done:
    popad ; restore registers
    ret ; return to caller address
