org 0x7E00
bits 16
%define newline 0x0A, 0x0D

jmp stageTwo

print:
    lodsb           ; AL = [SI], SI++
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x07
    int 0x10
    cmp byte [si], 0
    je .done
    jmp print

.done:
    ret
enterlong:
    mov eax, 0x80000001
    cpuid
    and edx, 0x20000000
    cmp edx, 0
    je .notSupportsLong
    jmp .supportsLong
.notSupportsLong:
    mov si, notlong
    call print
    jmp $
.supportsLong:
    mov si, islong
    call print
    jmp .finallyEnterLong
.finallyEnterLong:
    jmp $

.done:
    ret

stageTwo:
    mov si, stageTwoLoaded
    call print
    call enterlong
    jmp $

stageTwoLoaded: db newline, "loaded stage two moving to 64 bit mode", 0
notlong: db newline, "cpu does not support long mode. Your computer may be 32 bits", 0
islong: db newline, "cpu supports long mode", 0