[bits 32]
a equ 1103515245
c equ 12345


; CAN'T GIVE RESULTS LARGER THAN 2^32-1
; Parameters:
; EAX: base
; EBX: exponent
; Returns:
; EAX: result
power:
    push ebx
    push ecx
    push edx 
    mov ecx, eax ; store base in ecx

    test ebx, ebx ; look if the exponent is positive, negative or zero
    jz .zero
    jns .positive
    js .negative

    .zero:
        mov eax, 1
        jmp .end 

    .positive:
        dec ebx
        cmp ebx, 0 ; if the exponent was one, no multiplication
        jz .end
        mul ecx ; multiply eax with the base
        jmp .positive

    .negative: 
        mov eax, 0

    .end: 
    pop edx
    pop ecx
    pop ebx
    ret


; Changes the seed of the random function
; Parameters:
; EBX: seed
; Returns: 
; None
srand:
    mov dword [NEXT + KERNEL_OFFSET], ebx
    ret


; Parameters:
; None
; Returns: 
; EBX: random number between 0 and 32767
rand:
    push eax
    push edx

    mov eax, dword [NEXT + KERNEL_OFFSET] ; get next
    
    ; next_i+1 = next_i * a + c
    mov ebx, a
    mul ebx
    add eax, c
    

    mov dword [NEXT + KERNEL_OFFSET], eax ; update 

    ; for a number between 0 and 32767
    mov edx, 0
    mov ebx, dword 65536
    div ebx
    mov edx, 0
    mov ebx, dword 32768
    div ebx
    mov ebx, edx

    pop edx
    pop eax
    ret


NEXT: ; For the random number generator
    dd 1