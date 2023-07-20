[bits 32]

; Row/column structure used
start_game_rc:
    pushad

    call disable_cursor
    
    .game_loop:
        mov ebx, 65536 ; bigger number than it can possibly be
        push ebx ; to prepare the end of the stack
        mov cl, MAX_ROWS

        .row_nb_loop: ; row neighbors loop
            dec cl
            mov ch, MAX_COLS
            .col_nb_loop:
                dec ch

                mov bl, cl
                mov bh, ch

                mov edx, 0 ; counts number of neighbors of cell number ecx

                ; left and right
                dec bl
                call check_rc
                add bl, 2
                call check_rc

                ; top row
                dec bh
                call check_rc
                dec bl
                call check_rc
                dec bl
                call check_rc

                ; bottom row
                add bh, 2
                call check_rc
                inc bl
                call check_rc
                inc bl
                call check_rc

                ; EDX is now the amount of live neighbors of the cell
                ; check if the cell itself is alive
                mov bl, cl
                mov bh, ch
                call alive_rc
                test al, al
                jz .dead

                ; alive:
                cmp edx, 1
                jle .kill
                cmp edx, 3
                jg .kill
                jmp .end

                .dead:
                cmp edx, 3
                je .create
                jmp .end

                ; Killing and creating is only done at the end of the counting
                ; Push cells to be changed on stack. Lower element is the position
                ; higher element is 1 for create, 0 for kill
                .kill:
                    mov edx, 0
                    push edx
                    push ebx
                    jmp .end
                .create:
                    mov edx, 1
                    push edx
                    push ebx
                .end:

                test ch, ch
                jnz .col_nb_loop

            test cl, cl
            jnz .row_nb_loop
        

        ; Kill and create all cells on stack
        .update_loop:
            pop ebx
            cmp ebx, 65536
            je .end_update_loop
            pop edx
            test edx, edx
            jz .update_kill

            ; create:
            call create_cell_rc
            jmp .update_loop

            .update_kill:
            call kill_cell_rc
            jmp .update_loop

        .end_update_loop:

        ; sleep for 250 ms
        mov ebx, 250
        call sleep
        ; check if the game is not turned off
        mov al, byte [RUNNING + KERNEL_OFFSET]
        test al, al
        jnz .game_loop

    mov byte [RUNNING + KERNEL_OFFSET], 0
    mov byte [INIT_MODE + KERNEL_OFFSET], 0
    call enable_cursor

    popad

    ret ; return to home, in kernel.asm


check_rc:
    push eax
    call alive_rc
    test al, al
    jz .end ; don't add to live neighbors if cell is dead
    inc edx ; cell is alive, add one to live neighbors
    
    .end: 
    pop eax
    ret

; Parameters:
; bl: rows, bh: cols
; Returns:
; al = 0 if dead
; al = 1 if alive
alive_rc:
    push ebx
    push edx
    push ecx
    
    cmp bl, 255
    je .right
    cmp bl, MAX_ROWS
    je .left
    jmp .end_row_check

    .left:
        mov bl, 0
        jmp .end_row_check
    .right:
        mov bl, MAX_ROWS - 1
    .end_row_check:

    cmp bh, 255
    je .bottom
    cmp bh, MAX_COLS
    je .top
    jmp .end_col_check

    .top:
        mov bh, 0
        jmp .end_col_check
    .bottom:
        mov bh, MAX_COLS - 1
    .end_col_check:

    mov ecx, 0
    mov cl, bl
    mov eax, MAX_COLS
    mul ecx

    mov ecx, eax
    shr bx, 8
    add cx, bx

    mov ebx, ecx

    shl ebx, 1 ; double ebx, two bytes per cell in video_memory
    inc ebx ; second byte stores style of character
    add ebx, VIDEO_MEMORY

    mov al, byte [ebx]
    cmp al, byte WHITE_ON_WHITE
    je .alive

    .dead:
    mov al, 0
    jmp .end
    .alive: 
    mov al, 1

    .end:
    pop ecx
    pop edx
    pop ebx
    ret


; Parameters:
; bl: rows, bh: cols
; Returns: 
; None
create_cell_rc:
    pushad

    mov ecx, 0
    mov cl, bl
    mov eax, MAX_COLS
    mul ecx

    mov ecx, eax
    shr bx, 8
    add cx, bx

    mov ebx, ecx

    shl ebx, 1 ; double ebx, two bytes per cell in video_memory
    inc ebx ; second byte stores style of character
    add ebx, VIDEO_MEMORY

    mov byte [ebx], WHITE_ON_WHITE

    popad
    ret


; Parameters:
; bl: rows, bh: cols
; Returns: 
; None
kill_cell_rc:
    pushad

    mov ecx, 0
    mov cl, bl
    mov eax, MAX_COLS
    mul ecx

    mov ecx, eax
    shr bx, 8
    add cx, bx

    mov ebx, ecx

    shl ebx, 1 ; double ebx, two bytes per cell in video_memory
    inc ebx ; second byte stores style of character
    add ebx, VIDEO_MEMORY

    mov byte [ebx], WHITE_ON_BLACK

    popad
    ret


; THE NEXT THREE FUNCTIONS ARE USED BY THE SPACEBAR
; Parameters:
; EBX: position
; Returns:
; al = 0 if dead
; al = 1 if alive
alive:
    push ebx

    ; STATIC BOUNDS
    ; check if not out of bounds
    cmp ebx, dword SIZE
    jge .dead

    shl ebx, 1 ; double ebx, two bytes per cell in video_memory
    inc ebx ; second byte stores style of character
    add ebx, VIDEO_MEMORY

    mov al, byte [ebx]
    cmp al, byte WHITE_ON_WHITE
    je .alive

    .dead:
    mov al, 0
    jmp .end
    .alive: 
    mov al, 1

    .end:
    pop ebx
    ret


; Paramters:
; EBX: position
; Returns: 
; None
create_cell:
    pushad

    shl ebx, 1
    add ebx, VIDEO_MEMORY
    inc ebx
    mov al, WHITE_ON_WHITE
    mov byte [ebx], al

    popad
    ret


; Parameters:
; EBX: position
; Returns: 
; None
kill_cell:
    pushad

    shl ebx, 1
    add ebx, VIDEO_MEMORY
    inc ebx
    mov al, WHITE_ON_BLACK
    mov byte [ebx], al

    popad
    ret

RUNNING:
    db 0