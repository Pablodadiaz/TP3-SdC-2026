.code16
.global _start

_start:
    mov $msg, %si
    mov $0x0e, %ah

print_loop:
    lodsb
    or %al, %al
    jz halt
    int $0x10
    jmp print_loop

halt:
    hlt
    jmp halt

msg:
    .ascii "FFFFF  CCCCC  EEEEE  FFFFF  Y   Y  N   N\r\n"
    .ascii "F      C      E      F       Y Y   NN  N\r\n"
    .ascii "FFFF   C      EEEE   FFFF     Y    N N N\r\n"
    .ascii "F      C      E      F        Y    N  NN\r\n"
    .ascii "F      CCCCC  EEEEE  F        Y    N   N\r\n"
    .byte 0
