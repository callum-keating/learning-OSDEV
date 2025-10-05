org 0x7E00
bits 16

two_start:
    ; setup registers
    cli
    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    ; print messages
    mov si, message
    call .print_loop
    mov si, loadFAT_msg 
    call .print_loop

    ; load sector one into buffer
    mov ah, 0x02            ; read function
    mov al, 1               ; read one sector
    mov ch, 0               ; first cylinder
    mov cl, 1               ; first sector
    mov dh, 0               ; first head of drive
    mov es, ax              ; buffer
    mov bx, sectorBuf       ; the buffer to store it in
    ; leave dl untouched, it is the boot device
    int 13h ; call interupt


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
loadFAT_msg: db 0x0A, 0x0D, "now attempting to read fat filesystem", 0
sectorBuf: times 512 db 0
times 5120 - ($ - $$) db 0