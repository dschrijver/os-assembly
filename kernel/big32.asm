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


mul_two_big32:
    ; Multiplies two big32's with the same amount of 
    ; 32-bit limbs. The result is stored in a bigint of
    ; twice amount of 32-bit limbs. The function expects
    ; The output big32 to be zero initially. 
    ;
    ; Parameters
    ; ----------
    ; EBX: Number of 32-bit limbs in each input big32
    ; ESI: Pointer to 1st input big32
    ; EDI: Pointer to 2nd input big32
    ; EDX: Pointer to output big32

    pushad
    push ebp
    mov ebp, esp

    mov dword [ebp - 4], ebx
    mov dword [ebp - 8], esi
    mov dword [ebp - 12], edi
    mov dword [ebp - 16], edx
    sub esp, 16

    mov ebx, 0
    .loop1:
        mov ecx, 0
        .loop2:
            mov eax, dword [esi + 4*ebx]
            mov edx, dword [edi + 4*ecx]
            mul edx

            ; TODO!

            inc ecx
            cmp ebx, dword [ebp - 4]
            jne .loop2
            
        inc ebx
        cmp ebx, dword [ebp - 4]
        jne .loop1

    mov esp, ebp
    pop ebp
    popad
    ret
