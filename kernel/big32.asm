[bits 32]


print_hex_big32:
    ; Prints a big32, an integer of a specified
    ; amount of 32-bit limbs.
    ;
    ; Parameters
    ; ----------
    ; EBX: Number of 32-bit limbs in big32
    ; ESI: Pointer to source big32

    push ebx
    push ecx

    mov ecx, ebx
    .loop:
        dec ecx
        mov ebx, dword [edi + 4*ecx]
        call print_hex
        mov bl, ' '
        call cprint
        test ecx, ecx
        jnz .loop

    pop ecx
    pop ebx
    ret


rand_big32:
    ; Gives a random number of specified number
    ; of 32-bit limbs. 
    ;
    ; Parameters
    ; ----------
    ; EBX: Number of 32-bit limbs in big32
    ; EDI: Pointer to destination big32

    push eax
    push ecx

    mov ecx, ebx
    .loop:
        dec ecx
        call rand32
        mov dword [edi + 4*ecx], eax
        test ecx, ecx
        jnz .loop
    
    pop ecx
    pop eax
    ret
