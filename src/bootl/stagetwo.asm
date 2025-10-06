org 0x7E00
bits 16
%define newline 0x0A, 0x0D

jmp stageTwo


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

read_fail:
    mov si, readPartitionSectorFailMsg
    call print
    jmp $

stageTwo:
    ; setup registers
    cli
    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov [bootDisk], dl
    mov si, loadFATMsg
    call print
    ; load first sector that was stored in memory in stage one into the si register
    mov si, 0x0500
    mov dl, [bootDisk]
    call findFAT


    jmp $
findFAT:
    add si, 4
    cmp byte [si], 0x0c
    je .success
    sub si, 4
    add si, 16
    cmp si, 0x0540
    jge .failure
    jne findFAT

.success:
    push si
    mov si, foundFATMsg
    call print
    pop si
    add si, 4               ; Get to LBA address of start sector

    mov ax, [si]            ; mov the first 2 bytes of the LBA to ax
    mov [dap + 8], ax       ; mov ax to dap + 8 (First 2 bytes) 

    mov ax, [si + 2]        ; mov the second 2 bytes of the LBA to ax
    mov [dap + 10], ax      ; mov ax to dap + 10 filling in the low bytes.

    xor ax, ax              ; Zero ax
    mov [dap + 12], ax      ; Zero out the first 2 bytes of the high
    mov [dap + 14], ax      ; Zero out the second 2 bytes of the high

    ; CURRENT DAP STRUCTURE
    ; 0x10                  TELLS BIOS DAP IS 16 BYTES
    ; 0x00                  RESERVED BYTES
    ; 1                     TELLS BIOS TO READ ONE SECTOR (512 BYTES)
    ; buffer                WHERE SHOULD THE BIOS WRITE IT TO
    ; bufferSegment         SEGMENT:OFFSET OF BUFFER
    ; LBAOfPartition        AREA BIOS READS FROM

    ; Call interupt
    mov ah, 0x42            ; Extended read
    mov si, dap             ; disk address packet to use
    int 0x13
    jc read_fail
    mov si, buffer + 0x10
    call print

    ret
.failure:
    mov si, notFoundFATMsg
    call print
    jmp $

loadFATMsg:                 db newline, "Finding FAT filesystem", 0
foundFATMsg:                db newline, "Found FAT filesystem", newline, "now searching BPB", 0
notFoundFATMsg:             db newline, "FAILED TO FIND FAT FILESYSTEM PARTITION THE PARTITION TABLE MAY BE CORRUPTED", 0
readingFATMsg:              db newline, "Finding required entrys in bpb", 0
readPartitionSectorFailMsg: db newline, "Failed calling BIOS interupt to read FAT filesystem", 0
bootDisk:                   db 0
dap:
    db 0x10                 ; DAP is 16 bytes long
    db 0x00                 ; Reserved
    dw 1                    ; How many sectors should be read
    dw buffer               ; Where to load it too
    dw 0x0000               ; Buffer segment
    dq 0x0000000000000800   ; Start of read area

buffer:
    times 512 db 0
