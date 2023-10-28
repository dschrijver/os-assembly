[bits 32]
; The boot sector is loaded to 0x7c00, and its size is 0x200 bytes. 
; The heap will be right on top of that, growing upwards. 
HEAP_BASE equ 0x7e00


malloc:
    ; Allocates memory of a specified amount of bytes on the heap,
    ; and returns a pointer to this memory.
    ;
    ; Parameters
    ; ----------
    ; EBX: Size of memory to allocate in bytes
    ;
    ; Returns
    ; -------
    ; EAX: Pointer to allocated memory on the heap

    mov eax, dword [HEAP_POINTER + KERNEL_OFFSET]
    add dword [HEAP_POINTER + KERNEL_OFFSET], ebx
    ret


free:
    ; Frees memory of a specified amount of bytes from the heap.
    ;
    ; Parameters
    ; ----------
    ; EBX: Amount of bytes to free from the top of the heap.

    sub dword [HEAP_POINTER + KERNEL_OFFSET], ebx
    ret


malloc32:
    ; Allocates memory of a specified amount 32-bit limbs
    ; on the heap, and returns a pointer to this memory.
    ;
    ; Parameters
    ; ----------
    ; EBX: Size of memory to allocate in 32-bit limbs
    ;
    ; Returns
    ; -------
    ; EAX: Pointer to allocated memory on the heap

    push ebx

    shl ebx, 2
    mov eax, dword [HEAP_POINTER + KERNEL_OFFSET]
    add dword [HEAP_POINTER + KERNEL_OFFSET], ebx

    pop ebx
    ret


free32:
    ; Frees memory of a specified amount of 32-bit limbs from the heap.
    ;
    ; Parameters
    ; ----------
    ; EBX: Amount of 32-bit limbs to free from the top of the heap.

    push ebx
    
    shl ebx, 2
    sub dword [HEAP_POINTER + KERNEL_OFFSET], ebx

    pop ebx
    ret


; Pointer to next item on the heap
HEAP_POINTER:
    dd HEAP_BASE