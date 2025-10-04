org 0x7c00
bits 16

jmp entry


entry:
    xor  ax, ax
    mov  ds, ax
    mov  es, ax
    mov  fs, ax
    mov  gs, ax
    mov  ss, ax
    mov  sp, 0x7C00
    cli               ; Clear interrupts
    ; Entry for CDOS
    mov si, message
    call print
    ; load stage 2
    ; Setup stack
    xor ax, ax
    mov ss, ax
    mov sp, 0x7C00

    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov bx, 0x2000
    xor ax, ax
    mov es, ax
    mov ax, 0x0000
    mov ah, 0x02    ; read sectors from disk instruction
    mov al, 10
    int 13h         ; call interupt to load stage 2
    jc disk_error

    mov ax, 0x0200
    mov ds, ax
    mov ss, ax
    mov sp, 0x7c00
    jmp 0x0200:0x0000

print:
    lodsb           ; AL = [SI], SI++
    cmp al, 0
    je .done
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x07
    int 0x10
    jmp print
.done:
    ret



end:
    hlt                 ; halt the CPU
    jmp end
disk_error:
    ; Print error, halt will implement later.
    mov si, disk_error_message
    call print
.halt:
    cli
    hlt
    jmp .halt           ; incase of interupt (shouldnt happen)

message: db "Loading second stage", 0
disk_error_message: db "ERROR OCCURRED LOADING SECOND STAGE OF BOOTLOADER", 0

times 446 - ($ - $$) db 0       ; pad to 446 (start of partition table)
times 64 db 0                   ; reserve space for partition table
dw 0xAA55                       ; boot signature