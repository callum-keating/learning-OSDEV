bits 16
org 0x7c00

jmp entry

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


entry:
    ; Entry for CDOS
    mov si, message
    call print

end:
    hlt                 ; halt the CPU


message: db "Loading C bootloader", 0


times 446 - ($ - $$) db 0
times 64 db 0
dw 0xAA55