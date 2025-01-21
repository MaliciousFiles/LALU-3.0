// R31 = failed assertion idx (0 for success)
// R30 = calculated value
// R29 = expected value

.CODE
main:
    mov.e   R0, #0xFFFFFFFF
    mov     R1, #0x00000001
    add.s   R2, R0, R1 // set carry to 1

    // test RADD                        [1]
    radd    R30, #0, #0
    mov     R29, #1
    call    assert:

    // test RSUB                        [2]
    rsub    R30, #10, #9
    mov     R29, #2
    call    assert:

    // test CSUB, Rs1 < Rs0             [3]
    csub    R30, #10, #8
    mov     R29, #2
    call    assert:

    // test CSUB, Rs1 > Rs0             [4]
    csub    R30, #8, #10
    mov     R29, #8
    call    assert:

    mov.e   R0, #0x0559A04D
    mov.e   R1, #0x016A644D
    mul     R2, R0, R1
    ulmul   R3, R0, R1
    lumul   R4, R0, R1
    uumul   R5, R0, R1
    // test 32-bit MUL lower half       [5]
    adds.s  R30, R2, R3, #16
    radd    R5, R5, #0
    adds.s  R30, R30, R4, #16
    radd    R5, R5, #0
    mov.e   R29, #0x4B754B29
    call    assert:
    // test 32-bit MUL upper half       [6]
    addrs   R30, R5, R3, #16
    addrs   R30, R30, R4, #16
    mov.e   R29, #0x000792D5
    call    assert:

    // test ABS                         [7]
    mov.e   R0, #0xFFFFFFFF
    abs     R30, R0
    mov.e   R29, #0x7FFFFFFF
    call    assert:

    mov.e   R0, #0xFFFFFFFF // -1
    mov.e   R1, #0xFFFFFFFE // -2
    mov     R2, #0x1        //  1
    mov     R3, #0x2        //  2

    // test UMAX neg/neg                [8]
    umax    R30, R0, R1
    mov     R29, R0
    call    assert:
    // test UMAX pos/pos                [8] // TODO: update indices
    umax    R30, R2, R3
    mov     R29, R3
    call    assert:
    // test UMAX pos/neg                [9]
    umax    R30, R2, R1
    mov     R29, R1
    call    assert:

    // test UMIN neg/neg                [A]
    umin    R30, R1, R0
    mov     R29, R1
    call    assert:
    // test UMIN pos/pos                [B]
    umin    R30, R3, R2
    mov     R29, R2
    call    assert:
    // test UMIN pos/neg                [C]
    umin    R30, R1, R2
    mov     R29, R2
    call    assert:

    // test SMAX neg/neg                [D]
    smax    R30, R1, R0
    mov     R29, R0
    call    assert:
    // test SMAX pos/pos                [E]
    smax    R30, R3, R2
    mov     R29, R3
    call    assert:
    // test SMAX pos/neg                [F]
    smax    R30, R1, R2
    mov     R29, R2
    call    assert:

    // test SMIN neg/neg                [10]
    smin    R30, R0, R1
    mov     R29, R1
    call    assert:
    // test SMIN pos/pos                [11]
    smin    R30, R2, R3
    mov     R29, R2
    call    assert:
    // test SMIN pos/neg                [12]
    smin    R30, R2, R1
    mov     R29, R1
    call    assert:

    mov     R31, #0
    susp

assert:
    add     R31, R31, #1
    ne      R30, R29
    c.susp
    ret