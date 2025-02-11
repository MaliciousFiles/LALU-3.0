// R31 = failed assertion idx (0 for success)
// R30 = calculated value
// R29 = expected value
// R28 = VGA write sector
// R27 = VGA write index
jmp main:

.DATA
    I_MSG: "I"
    V_MSG: "V"
    E_MSG: "E"

.CODE
main:
    // test RADD                        [1]
    mov.e   R0, #0xFFFFFFFF
    mov     R1, #0x00000001
    add.s   R2, R0, R1 // set carry to 1
    radd    R30, #0, #0
    mov     R29, #1
    call    assert:

    // test RSUB                        [2]
    mov.e   R0, #0xFFFFFFFF
    mov     R1, #0x00000001
    add.s   R2, R0, R1 // set carry to 1
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

    // test 32-bit MUL lower half       [5]
    mov.e   R0, #0x0559A04D
    mov.e   R1, #0x016A644D
    mul     R2, R0, R1
    ulmul   R3, R0, R1
    lumul   R4, R0, R1
    uumul   R5, R0, R1
    adds.s  R30, R2, R3, #16
    radd    R5, R5, #0
    adds.s  R30, R30, R4, #16
    radd    R5, R5, #0
    mov.e   R29, #0x4B754B29
    call    assert:
    // test 32-bit MUL upper half       [6]
    mov.e   R0, #0x0559A04D
    mov.e   R1, #0x016A644D
    mul     R2, R0, R1
    ulmul   R3, R0, R1
    lumul   R4, R0, R1
    uumul   R5, R0, R1
    add     R30, R5, R3
    add     R30, R30, R4
    mov.e   R29, #0x03029C81
    call    assert:

    // test ABS                         [7]
    mov.e   R0, #0xFFFFFFFF
    abs     R30, R0
    mov     R29, #1
    call    assert:

    mov.e   R0, #0xFFFFFFFF // -1
    mov.e   R1, #0xFFFFFFFE // -2
    mov     R2, #0x1        //  1
    mov     R3, #0x2        //  2

    // test UMAX neg/neg                [8]
    umax    R30, R0, R1
    mov     R29, R0
    call    assert:
    // test UMAX pos/pos                [9]
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
    mov.e   R29, #0b00000000000100001000010000100001
    call    assert:

    // test EXS                         [1D]
    exs.e   R30, #0b01010001010001010111010101000101, #10
    mov.e   R29, #0b11111111111111111111110101000101
    call    assert:

    // test LSB                         [1E]
    lsb.e   R30, #0b00000001010001010111010101000000
    mov.e   R29, #0b1000000
    call    assert:

    // test HSB                         [1F]
    hsb.e   R30, #0b00000001010001010111010101000000
    mov.e   R29, #0b1000000000000000000000000
    call    assert:

    mov.e   R5, #0b1010101011010100110
    // test ST/LD                       [20]
    st      R5, R5, #1, #13     // should set mem[R5] to 0b10110101001100000000
    ld      R30, R5, #4, #8
    mov.e   R29, #0b11010100
    call    assert:

    // test BSF                         [21]
    mov.e   R30, #0b00000001010101010111010101000000
    bsf     R30, R30, #7, #13
    mov.e   R29, #0b0101011101010
    call    assert:

    // test BST                         [22]
    mov.e   R30, #0b00000001010001010111010101000000
    mov.e   R29, #0b01101010110001011110101010101011
    bst     R30, R29, #2, #11
                //0b00000001010001010110101010101100
                //0b00000001010001010110001010101011
    mov.e   R29, #0b00000001010001010110101010101100
    call    assert:

    // test VADD                        [23]
    mov.e   R30, #0b10101010111010110010101101010111
    vadd.e  R30, R30, #0b10101111101010001010101110101010, #5
    mov.e   R29, #0b00011000100000111101001011100001
    call    assert:

    // test VSUB                        [24]
    mov.e   R30, #0b10101010111010110010101101010111
    vsub.e  R30, R30, #0b10101111101010001010101110101010, #5
    mov.e   R29, #0b00111101010000101000001110101101
    call    assert:

    // test ADD                         [25]
    mov.e   R30, #3923142388
    add.e   R30, R30, #1272556588
    mov.e   R29, #0b00110101101100000001001100100000
    call    assert:
    // test ADD - CF                    [26]
    radd    R30, #0, #0
    mov     R29, #1
    call    assert:
    // test ADD - OF                    [27]
    of
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:

    // test SUB                         [28]
    sub     R30, #0, #1
    mov.e   R29, #0b11111111111111111111111111111111
    call    assert:
    // test SUB - CF                    [29]
    radd    R30, #0, #0
    mov     R29, #1
    call    assert:
    // test SUB - OF                    [2A]
    of
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:

    // test ADDS                        [2B]
    mov.e   R30, #38012384
    adds.e  R30, R30, #3480912, #10
    mov.e   R29, #3602466272
    call    assert:

    // test ADDRS                       [2C]
    mov     R30, #30
    addrs.e R30, R30, #3480930212, #16
    mov.e   R29, #53144
    call    assert:

    // test CSUB (subtract)             [2D]
    csub.s  R30, #30, #15
    mov     R29, #15
    call    assert:
    // test CSUB (subtract) - CF        [2E]
    radd    R30, #0, #0
    mov     R29, #0
    call    assert:
    // test CSUB (don't subtract)       [2F]
    csub.s  R30, #4, #12
    mov     R29, #4
    call    assert:
    // test CSUB (don't subtract) - CF  [30]
    radd    R30, #0, #0
    mov     R29, #1
    call    assert:

    // test ABS (negative)              [31]
    abs.e   R30, #0b10101010111101010110111100010111
    mov.e   R29, #0b01010101000010101001000011101001
    call    assert:
    // test ABS (positive)              [32]
    abs.e   R30, #0b01010101000010101001000011101001
    mov.e   R29, #0b01010101000010101001000011101001
    call    assert:

    // test BSL                         [33]
    bsl.e   R30, #0b10101010111101010110111100010111, #12
    mov.e   R29, #0b01010110111100010111000000000000
    call    assert:

    // test BSR                         [34]
    bsr.e   R30, #0b10101010111101010110111100010111, #12
    mov.e   R29, #0b10101010111101010110
    call    assert:

    // test BRL                         [35]
    brl.e   R30, #0b10101010111101010110111100010111, #12
    mov.e   R29, #0b01010110111100010111101010101111
    call    assert:

    // test BRR                         [36]
    brr.e   R30, #0b10101010111101010110111100010111, #12
    mov.e   R29, #0b11110001011110101010111101010110
    call    assert:

    // test ANY (true)                  [37]
    any.e   R30, #0b10101010111101010110111100010111
    mov     R29, #1
    call    assert:
    // test ANY (false)                 [38]
    any     R30, #0
    mov     R29, #0
    call    assert:

    // test BIT                         [39]
    mov.e   R30,      #0b11000010101111010100010101000010
    bit.e   R30, R30, #0b10101010111101010110111100010111, #0b1010
    mov.e   R29,      #0b11000010101111010100010101000010
    call    assert:

    // test STW/LDW                     [3A]
    mov.e   R5, #0b1010101011010100110
    stw     R5, R5, #0b11010     // should set mem[R5+1] to 0b1010101011010100110
    mov.e   R5, #0b1010101011010101011
    ldw     R30, R5, #0b10101
    mov.e   R29, #0b1010101011010100110
    call    assert:

    // test MOV                         [3B]
    mov.e   R30, #0b1010101011010100110
    mov.e   R29, #0b1010101011010100110
    call    assert:

    // test CALl/RET/JMP                [3C]
    mov     R30, #0
    jmp     after:
fn:
    mov     R30, #1
    ret
after:
    call    fn:
    mov     R29, #1
    call    assert:
    
    // test UGT - pos/pos               [3D]
    mov.e   R30, #0b10110101010001110111110
    ugt.e   R30, #0b1010101011010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:
    // test UGT - pos/neg               [3E]
    mov.e   R30, #0b10110101010001110111110
    ugt.e   R30, #0b11010101011010101010101010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:
    // test UGT - neg/neg               [3F]
    mov.e   R30, #0b11011010101001001010001110111110
    ugt.e   R30, #0b11010101011010101010101010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:
    // test UGT - equal                 [40]
    mov.e   R30, #0b11011010101001001010001110111110
    ugt.e   R30, #0b11011010101001001010001110111110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:
    
    // test UGE - pos/pos               [41]
    mov.e   R30, #0b10110101010001110111110
    uge.e   R30, #0b1010101011010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:
    // test UGE - pos/neg               [42]
    mov.e   R30, #0b10110101010001110111110
    uge.e   R30, #0b11010101011010101010101010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:
    // test UGE - neg/neg               [43]
    mov.e   R30, #0b11011010101001001010001110111110
    uge.e   R30, #0b11010101011010101010101010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:
    // test UGE - equal                 [44]
    mov.e   R30, #0b11011010101001001010001110111110
    uge.e   R30, #0b11011010101001001010001110111110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:
    
    // test ULT - pos/pos               [45]
    mov.e   R30, #0b10110101010001110111110
    ult.e   R30, #0b1010101011010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:
    // test ULT - pos/neg               [46]
    mov.e   R30, #0b10110101010001110111110
    ult.e   R30, #0b11010101011010101010101010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:
    // test ULT - neg/neg               [47]
    mov.e   R30, #0b11011010101001001010001110111110
    ult.e   R30, #0b11010101011010101010101010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:
    // test ULT - equal                 [48]
    mov.e   R30, #0b11011010101001001010001110111110
    ult.e   R30, #0b11011010101001001010001110111110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:
    
    // test ULE - pos/pos               [49]
    mov.e   R30, #0b10110101010001110111110
    ule.e   R30, #0b1010101011010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:
    // test ULE - pos/neg               [4A]
    mov.e   R30, #0b10110101010001110111110
    ule.e   R30, #0b11010101011010101010101010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:
    // test ULE - neg/neg               [4B]
    mov.e   R30, #0b11011010101001001010001110111110
    ule.e   R30, #0b11010101011010101010101010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:
    // test ULE - equal                 [4C]
    mov.e   R30, #0b11011010101001001010001110111110
    ule.e   R30, #0b11011010101001001010001110111110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:

    // test SGT - pos/pos               [4D]
    mov.e   R30, #0b10110101010001110111110
    sgt.e   R30, #0b1010101011010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:
    // test SGT - pos/neg               [4E]
    mov.e   R30, #0b10110101010001110111110
    sgt.e   R30, #0b11010101011010101010101010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:
    // test SGT - neg/neg               [4F]
    mov.e   R30, #0b11011010101001001010001110111110
    sgt.e   R30, #0b11010101011010101010101010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:
    // test SGT - equal                 [50]
    mov.e   R30, #0b11011010101001001010001110111110
    sgt.e   R30, #0b11011010101001001010001110111110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:
    
    // test SGE - pos/pos               [51]
    mov.e   R30, #0b10110101010001110111110
    sge.e   R30, #0b1010101011010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:
    // test SGE - pos/neg               [52]
    mov.e   R30, #0b10110101010001110111110
    sge.e   R30, #0b11010101011010101010101010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:
    // test SGE - neg/neg               [53]
    mov.e   R30, #0b11011010101001001010001110111110
    sge.e   R30, #0b11010101011010101010101010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:
    // test SGE - equal                 [54]
    mov.e   R30, #0b11011010101001001010001110111110
    sge.e   R30, #0b11011010101001001010001110111110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:
    
    // test SLT - pos/pos               [55]
    mov.e   R30, #0b10110101010001110111110
    slt.e   R30, #0b1010101011010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:
    // test SLT - pos/neg               [56]
    mov.e   R30, #0b10110101010001110111110
    slt.e   R30, #0b11010101011010101010101010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:
    // test SLT - neg/neg               [57]
    mov.e   R30, #0b11011010101001001010001110111110
    slt.e   R30, #0b11010101011010101010101010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:
    // test SLT - equal                 [58]
    mov.e   R30, #0b11011010101001001010001110111110
    slt.e   R30, #0b11011010101001001010001110111110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:
    
    // test SLE - pos/pos               [59]
    mov.e   R30, #0b10110101010001110111110
    sle.e   R30, #0b1010101011010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:
    // test SLE - pos/neg               [5A]
    mov.e   R30, #0b10110101010001110111110
    sle.e   R30, #0b11010101011010101010101010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:
    // test SLE - neg/neg               [5B]
    mov.e   R30, #0b11011010101001001010001110111110
    sle.e   R30, #0b11010101011010101010101010100110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:
    // test SLE - equal                 [5C]
    mov.e   R30, #0b11011010101001001010001110111110
    sle.e   R30, #0b11011010101001001010001110111110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:

    // test EQ - equal                  [5D]
    mov.e   R30, #0b10110101010001110111110
    eq.e    R30, #0b10110101010001110111110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:
    // test EQ - not equal              [5E]
    mov.e   R30, #0b10110101010001110111110
    eq.e    R30, #0b01010101111010101010010
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:

    // test NE - equal                  [5F]
    mov.e   R30, #0b10110101010001110111110
    ne.e    R30, #0b10110101010001110111110
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:
    // test NE - not equal              [60]
    mov.e   R30, #0b10110101010001110111110
    ne.e    R30, #0b01010101111010101010010
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:

    // test NF - neg                    [61]
    mov.e.s R30, #0b10000100110101010001111110111110
    nf
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:
    // test NF - pos                    [62]
    mov.e.s R30, #0b00000100110101010001111110111110
    nf
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:

    // test ZF - zero                   [63]
    mov.s   R30, #0
    zf
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #1
    call    assert:
    // test ZF - non-zero               [64]
    mov.s   R30, #1
    zf
    c.mov   R30, #1
    cn.mov  R30, #0
    mov     R29, #0
    call    assert:

    // test VLB                         [65]
    vlb     R30, #6
    mov.e   R29, #0b01000001000001000001000001000001
    call    assert:

    // test VHB                         [66]
    vhb     R30, #6
    mov.e   R29, #0b00100000100000100000100000100000
    call    assert:

    // test DAB                         [67]
    dab.e   R30, #0b00100101011010100110
    mov.e   R29, #0b00101000100111011001
    call    assert:

    // fail assertion
    mov.e   R30, #0x61460
    mov.e   R29, #0x4D6
    call    assert:

ex:
    jmp ex:

assert:
    add     R31, R31, #1
    ne      R30, R29
    c.call  print_debug:
    ret

print_debug:
    bsl     R27, R28, #5
    add     R28, R28, #1

    mov.e   R15, I_MSG:
    mov     R16, #0b00000001
    mov.e   R17, #0xf58484
    mov.e   R18, #0xf24141
    call    print_str:
    add     R27, R27, #1

    mov     R15, R31
    mov     R16, #0b00000000
    mov.e   R17, #0xed1818
    mov     R18, #0
    mov     R19, #0
    call    print_reg:
    add     R27, R27, #2

    mov.e   R15, V_MSG:
    mov     R16, #0b00000001
    mov.e   R17, #0xf58484
    mov.e   R18, #0xf24141
    call    print_str:
    add     R27, R27, #1

    mov     R15, R30
    mov     R16, #0b00000000
    mov.e   R17, #0xed1818
    mov     R18, #0
    mov     R19, #1
    call    print_reg:
    add     R27, R27, #2

    mov.e   R15, E_MSG:
    mov     R16, #0b00000001
    mov.e   R17, #0xbfbfbf
    mov.e   R18, #0xf0f0f0
    call    print_str:
    add     R27, R27, #1

    mov     R15, R29
    mov     R16, #0b00000000
    mov.e   R17, #0xe6e6e6
    mov     R18, #0
    mov     R19, #1
    call    print_reg:

    ret

// put str addr in R15
// put flags in R16
// put FG in R17
// put BG in R18
print_str:
    lda     R13, R15, #8
    add     R15, R15, #8

    ne      R13, #0
    c.adds  R13, R13, R16, #8

    c.stchr R13, R27, R17, R18
    c.add   R27, R27, #1

    c.jmp   print_str:

    ret

// put number in R15
// put flags in R16
// put FG in R17
// put BG in R18
// R19 = whether to print leading 0s
print_reg:
    eq      R19, #0
    c.log   R14, R15
    c.andn  R14, R14, #0b11
    cn.mov  R14, #28
loop:
    bsf     R13, R15, R14, #4
    sub     R14, R14, #4

    csub.s  R13, R13, #10
    cf
    c.add.e R13, R13, #48
    cn.add.e R13, R13, #65

    adds    R13, R13, R16, #8
    stchr   R13, R27, R17, R18
    add     R27, R27, #1

    sge     R14, #0
    c.jmp   loop:

    ret