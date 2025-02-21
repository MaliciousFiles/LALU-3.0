jmp main:

.DATA
    X: [32d'12]

.CODE
main:
    mov.e R0, X:
    ldw R0, R0, #0
    call fac:
    gcld R0
    nop
    nop
    susp

fac:
    eq R1, #0
    c.mov R1, #1

    eq R0, #0
    c.ret

    call mul32:
    sub R0, R0, #1
    call fac:
    ret


// R1 = R0 * R1
mul32:
    mul R5, R0, R1
    uumul R6, R0, R1
    ulmul R7, R0, R1
    lumul R8, R0, R1

    adds R1, R5, R6, #16
    adds R1, R1, R7, #16
    adds R1, R1, R8, #16

    ret