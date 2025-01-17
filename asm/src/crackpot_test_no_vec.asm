.CODE
main:
    mov.e   R0, #0xFFFFFFFF
    mov     R1, #0x00000001
    add.s   R2, R0, R1 // set carry to 1

    // test RADD
    radd    R30, #0, #0
    mov     R29, #1
    call    assert:

    // test RSUB
    rsub    R30, #10, #9
    mov     R29, #2
    call    assert:

    // test CSUB, Rs1 < Rs0
    csub    R30, #10, #8
    mov     R29, #2
    call    assert:

    // test CSUB, Rs1 > Rs0
    csub    R30, #8, #10
    mov     R29, #8
    call    assert:

    // test 32-bit MULs
    mov.e   R0, #0x0559A04D
    mov.e   R1, #0x016A644D
    mul     R2, R0, R1
    uumul   R3, R0, R1
    ulmul   R4, R0, R1
    lumul   R5, R0, R1
    add     R30,


    mov     R31, #0
    susp

// assert that R30 == R29, otherwise suspend with R31 as the assertion index
assert:
    add     R31, R31, #1
    ne      R30, R29
    c.susp
    ret