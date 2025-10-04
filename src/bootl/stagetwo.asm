org 0x0000
bits 16

two_start:
    mov ax, 0x0200
    mov ds, ax
    mov ss, ax
    mov sp, 0x7C00

    mov si, message

.print_loop:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0E
    mov bh, 0
    mov bl, 7
    int 0x10
    jmp .print_loop
.done:
    jmp $

message: db 0x0A, 0x0D, "Stage 2 loaded successfully!", 0
times 5120 - ($ - $$) db 0
