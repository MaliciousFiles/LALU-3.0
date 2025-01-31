// R0 = scan code
// R1 = ascii
// R2 = break code
// R3 = lshft (bold)
// R4 = lctrl (italic)
// R5 = lalt (underline)
// R6 = lwin (strike)
// R7 = rshft (flip H)
// R8 = ralt (flip V)
// R31 = address

    rstkey

begin:
    ldkey   R0

    // if we got nothing, ignore
    eq      R0, #0
    c.jmp   begin:

    // if it's a release, ignore
    bsf     R2, R0, #17, #1
    eq      R2, #1
    c.jmp   begin:

    bsf     R3, R0, #15, #1
    bsf     R4, R0, #16, #1
    bsf     R5, R0, #14, #1
    bsf     R6, R0, #13, #1
    bsf     R7, R0, #11, #1
    bsf     R8, R0, #10, #1

    bsf     R0, R0, #0, #7          // R0 = key code
    mov     R1, #0

    // A
    eq.e    R0, #0x4E
    c.mov.e R1, #65
    // B
    eq.e    R0, #0x5E
    c.mov.e R1, #66
    // C
    eq.e    R0, #0x5C
    c.mov.e R1, #67
    // D
    eq.e    R0, #0x50
    c.mov.e R1, #68
    // E
    eq.e    R0, #0x44
    c.mov.e R1, #69
    // F
    eq.e    R0, #0x51
    c.mov.e R1, #70
    // G
    eq.e    R0, #0x52
    c.mov.e R1, #71
    // H
    eq.e    R0, #0x53
    c.mov.e R1, #72
    // I
    eq.e    R0, #0x49
    c.mov.e R1, #73
    // J
    eq.e    R0, #0x54
    c.mov.e R1, #74
    // K
    eq.e    R0, #0x55
    c.mov.e R1, #75
    // L
    eq.e    R0, #0x56
    c.mov.e R1, #76
    // M
    eq.e    R0, #0x60
    c.mov.e R1, #77
    // N
    eq.e    R0, #0x5F
    c.mov.e R1, #78
    // O
    eq.e    R0, #0x4A
    c.mov.e R1, #79
    // P
    eq.e    R0, #0x4B
    c.mov.e R1, #80
    // Q
    eq.e    R0, #0x42
    c.mov.e R1, #81
    // R
    eq.e    R0, #0x45
    c.mov.e R1, #82
    // S
    eq.e    R0, #0x4F
    c.mov.e R1, #83
    // T
    eq.e    R0, #0x46
    c.mov.e R1, #84
    // U
    eq.e    R0, #0x48
    c.mov.e R1, #85
    // V
    eq.e    R0, #0x5D
    c.mov.e R1, #86
    // W
    eq.e    R0, #0x43
    c.mov.e R1, #87
    // X
    eq.e    R0, #0x5B
    c.mov.e R1, #88
    // Y
    eq.e    R0, #0x47
    c.mov.e R1, #89
    // Z
    eq.e    R0, #0x5A
    c.mov.e R1, #90

    ne      R1, #0
    c.bst   R1, R3, #8, #1
    c.bst   R1, R4, #9, #1
    c.bst   R1, R5, #10, #1
    c.bst   R1, R6, #11, #1
    c.bst   R1, R7, #12, #1
    c.bst   R1, R8, #13, #1
    c.stchr.e R1, R31, #0xFFFFFF, #0x0
    c.add   R31, R31, #1        // since width is precisely 2^6, automatically handles wrapping :D

    jmp begin: