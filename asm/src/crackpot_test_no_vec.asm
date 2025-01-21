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
    // test UMAX pos/pos                [9] // TODO: update indices
    umax    R30, R2, R3
    mov     R29, R3
    call    assert:
    // test UMAX pos/neg                [A]
    umax    R30, R2, R1
    mov     R29, R1
    call    assert:

    // test UMIN neg/neg                [B]
    umin    R30, R1, R0
    mov     R29, R1
    call    assert:
    // test UMIN pos/pos                [C]
    umin    R30, R3, R2
    mov     R29, R2
    call    assert:
    // test UMIN pos/neg                [D]
    umin    R30, R1, R2
    mov     R29, R2
    call    assert:

    // test SMAX neg/neg                [E]
    smax    R30, R1, R0
    mov     R29, R0
    call    assert:
    // test SMAX pos/pos                [F]
    smax    R30, R3, R2
    mov     R29, R3
    call    assert:
    // test SMAX pos/neg                [10]
    smax    R30, R1, R2
    mov     R29, R2
    call    assert:

    // test SMIN neg/neg                [11]
    smin    R30, R0, R1
    mov     R29, R1
    call    assert:
    // test SMIN pos/pos                [12]
    smin    R30, R2, R3
    mov     R29, R2
    call    assert:
    // test SMIN pos/neg                [13]
    smin    R30, R2, R1
    mov     R29, R1
    call    assert:

    // test LOG (not zero)              [14]
    log.e   R30, #0b1010111010101
    mov     R29, #12
    call    assert:
    // test LOG (zero)                  [15]
    log     R30, #0
    mov     R29, #0
    call    assert:

    // test CTZ                         [16]
    ctz.e   R30, #0b10110100000
    mov     R29, #5
    call    assert:
    // test CTZ (full)                  [17]
    ctz     R30, #0
    mov.e   R29, #32
    call    assert:
    // test CTZ (none)                  [18]
    ctz.e   R30, #0b101101000001
    mov     R29, #0
    call    assert:

    // test PCNT                        [19]
    pcnt.e  R30, #0b101101000001
    mov     R29, #5
    call    assert:

    // test BRVS                        [1A]
    brvs.e  R30, #0b00000001010001010111010111000101
    mov.e   R29, #0b10100011101011101010001010000000
    call    assert:

    // test SRVS                        [1B]
    srvs.e  R30, #0b10000001010001010111010111000101, #5
    mov.e   R29, #0b00000000010101010101110111010100
    call    assert:

    // test VANY                        [1C]
    vany.e  R30, #0b10000001010001010111010111000101, #5
    mov.e   R29, #0b01000000000100001000010000100001
    call    assert:

    // test EXS                         [1D]
    exs.e   R30, #0b00000001010001010111010101000101, #8
    mov.e   R29, #0b11111111111111111111111101000101
    call    assert:

    // test LSB                         [1E]
    lsb.e   R30, #0b00000001010001010111010101000000
    mov.e   R29, #0b1000000
    call    assert:

    // test HSB                         [1F]
    hsb.e   R30, #0b00000001010001010111010101000000
    mov.e   R29, #0b1000000000000000000000000
    call    assert:

    mov     R31, #0
    susp

assert:
    add     R31, R31, #1
    ne      R30, R29
    c.susp
    ret