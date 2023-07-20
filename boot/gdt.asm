; info: https://wiki.osdev.org/Global_Descriptor_Table
gdt:

.null_descriptor:
    dq 0x0 ; 8 bytes

; offset 8 bytes
.code_descriptor: ; cs register points to this descriptor in memory
    dw 0xffff ; first 15 bits of the limit of this segment
    dw 0x0 ; base first 15 bits
    db 0x0 ; base 16 - 23 bits
    db 10011010b ; Access byte
    db 11001111b ; lowest four bits are 16 - 19 of the limit
    db 0x0 ; rest of the base, 24 - 31

; offset 16 bytes
.data_descriptor:
    dw 0xffff
	dw 0x0
	db 0x0
	db 10010010b
	db 11001111b
	db 0x0	
.end:

gdtr: 
    dw gdt - gdt.end - 1 ; LIMIT of 2 bytes, size of gdt, 1 less than actual size
    dd gdt + 0x7c00 ; BASE of 4 bytes, start address of the gdt, manual offset