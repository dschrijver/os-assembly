; Parameters: 
; DH: amount of sectors to read 
; DL: boot disk number
; ES:BX: Location for the sectors to be written to

; Returns:
; Error message if there is a disk load error
; None

disk_load:
    pusha
    push dx ; to save how many sectors actually should have
    ; been read
    mov ah, 0x02 ; reading mode
    mov al, dh ; al should be amount of sectors to read
    mov ch, 0 ; cylinder number, starts counting at zero
    mov cl, 2 ; sector to start at, starts counting at 1
    mov dh, 0 ; head number

    ; dl is set to the drive number, floppy = 0, hdd = 0x80
    int 0x13 ; start reading interrupt
    jc disk_load_error ; jump if cf error flag is set
    pop dx ; retreive the sectors that should've been read from dh
    cmp al, dh ; al is actual sectors read count
    jne disk_load_error

    popa
    ret

disk_load_error:
    mov bx, DISK_LOAD_ERROR_MSG
    call print
    jmp $
