    mov    R4, #0

// normal
    mov    R3, #0b00000000
    call   render_alphabet:
// bold
    mov    R3, #0b00000001
    call   render_alphabet:
// italic
    mov    R3, #0b00000010
    call   render_alphabet:
// underline
    mov    R3, #0b00000100
    call   render_alphabet:
// strikethrough
    mov    R3, #0b00001000
    call   render_alphabet:
// flip horizontal
    mov    R3, #0b00010000
    call   render_alphabet:
// flip vertical
    mov.e  R3, #0b00100000
    call   render_alphabet:
// bold italic
    mov    R3, #0b00000011
    call   render_alphabet:
// bold underline
    mov    R3, #0b00000101
    call   render_alphabet:
// italic strikethrough
    mov    R3, #0b00001010
    call   render_alphabet:
// bold italic underline strikethrough
    mov    R3, #0b00001111
    call   render_alphabet:

ex:
    jmp ex:

// R3 = flags
// R4 = line
render_alphabet:
    mov.e   R31, #91                // end char
    adds    R31, R31, R3, #8

    mov.e   R1, #65                 // start char
    adds    R1, R1, R3, #8

    bsl     R2, R4, #6              // start address

loop:
    stchr.e R1, R2, #0x0, #0xFFFFFF

    add     R1, R1, #1
    add     R2, R2, #1

    eq      R1, R31
    c.add   R4, R4, #1
    c.ret

    jmp     loop: