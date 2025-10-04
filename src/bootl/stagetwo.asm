org 0x0000
bits 16

two_start:
    mov ax, 0x0200
    mov ds, ax
    mov ss, ax
    mov sp, 0x7C00

    mov si, message
    call .print_loop
    mov si, loadFAT_msg 
    call .print_loop
    jmp $

.print_loop:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0E
    mov bh, 0
    mov bl, 7
    int 0x10
    jmp .print_loop

;getKernel:
;    pass 

.done:
    ret

message: db 0x0A, 0x0D, "Stage 2 loaded successfully", 0 ; move down a line and move to the beginning
loadFAT_msg: db 0x0A, 0x0D, "now attempting to read fat filesystem starting at sector 11...", 0
times 5120 - ($ - $$) db 0
