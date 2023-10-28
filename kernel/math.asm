[bits 32]
RAND_MAX    equ 32767
RAND_A      equ 1103515245
RAND_C      equ 12345


power:
    ; Calculates pow(b, e) = b^e. Note that
    ; the result is stored in a 32bit register, and
    ; overflow is not handled. A negative exponent will 
    ; return zero. 
    ;
    ; Parameters
    ; ----------
    ; EAX: b (base)
    ; EBX: e (exponent)
    ;
    ; Returns
    ; -------
    ; EAX: pow(b, e)

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


srand:
    ; Change the seed of the Random Number Generator. 
    ; This is not required, as the seed will be
    ; set to 1 initially. 
    ;
    ; Parameters
    ; ----------
    ; EBX: seed

    mov dword [NEXT + KERNEL_OFFSET], ebx
    ret


rand:
    ; Gives a random number in the range [0, RAND_MAX).
    ; See https://www.open-std.org/jtc1/sc22/wg14/www/docs/n1570.pdf, page 347.
    ;
    ; Returns
    ; -------
    ; EAX: random number in the range [0, RAND_MAX)

    push ebx
    push ecx
    push edx

    mov eax, dword [NEXT + KERNEL_OFFSET] ; Get NEXT

    ; NEXT = a*NEXT + c
    mov ebx, RAND_A
    mul ebx
    add eax, RAND_C

    mov dword [NEXT + KERNEL_OFFSET], eax ; Update NEXT

    ; (NEXT / 2^16) % 2^15
    mov cl, 16
    shr eax, cl
    ; a % b = (b-1) & a
    mov ebx, 0x7fff
    and ebx, eax
    
    mov eax, ebx

    pop edx
    pop ecx
    pop ebx
    ret


rand16:
    ; Gives a random 16-bit number, in the range [0, 2^16-1].
    ; This is done by calling "rand" twice, once for the
    ; higher 15 bits and once for the lowest bit.
    ;    
    ; Returns
    ; -------
    ; EAX: A random number in the range [0, 2^16-1]

    push ebx

    call rand
    and eax, 1
    mov ebx, eax
    call rand
    shl eax, 1
    or eax, ebx

    pop ebx
    ret


rand32:
    ; Gives a random 32-bit number, in the range [0, 2^32-1].
    ; This is done by calling "rand16" twice, once for the
    ; higher 16 bits and once for the lower 16 bits.
    ;    
    ; Returns
    ; -------
    ; EAX: A random number in the range [0, 2^32-1]

    push ebx

    call rand16
    mov ebx, eax
    call rand16
    shl eax, 16
    or eax, ebx

    pop ebx
    ret


randrange:
    ; Gives a random number in the range [0, n),
    ; where "n" is a 32-bit integer. Skew is taken into account
    ; by only accepting values from "r" rand32 where r%n = 0.
    ;
    ; Parameters
    ; ----------
    ; EBX: n (the maximum)
    ;
    ; Returns
    ; -------
    ; EAX: A random number in the range [0, n)

    push ebx
    push edx

    ; end = ((2^32-1) // n) * n
    mov edx, 0
    mov eax, 0xffffffff
    div ebx
    mul ebx
    mov edx, eax

    ; while (r >= end)
    .try_random_number:
        call rand32
        cmp eax, edx
        jae .try_random_number
    
    mov edx, 0
    div ebx
    mov eax, edx

    pop edx
    pop ebx
    ret


; 32-bit seed for the Random Number Generator
NEXT: 
    dd 1