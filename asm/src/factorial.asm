jmp main:

.DATA
X: [32d'12]

.CODE
main:
    mov.e R0, X:
    ldw R0, R0, #0
    call fac:
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
    bsr R5, R0, #16     // R5 = R0.upper
    bsr R6, R1, #16     // R6 = R1.upper

    mul R7, R0, R1      // R7 = L1*L2

    mul R8, R0, R6      // R8 = L1*U2
    bsl R8, R8, #16

    mul R9, R1, R5      // R9 = U1*L2
    bsl R9, R9, #16

    mul R10, R5, R6     // R10 = U1*U2
    bsl R10, R10, #16

    add R1, R7, R8
    add R1, R1, R9
    add R1, R1, R10

    ret