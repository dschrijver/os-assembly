; Parameters: 
; BX: Pointer to base of string

; Returns:
; None
print:
    pusha ; save all registers on the stack
    mov ah, 0x0e ; set this for printing

.loop:
    mov al, [bx] ; put character at address of bx in al
    cmp al, 0
    je .done ; you arrived at the last character, so you're done

    int 0x10 ; print the character
    add bx, 1 ; move on to the next character
    jmp .loop

.done:
    popa ; retrieve all registers from stack
    ret
