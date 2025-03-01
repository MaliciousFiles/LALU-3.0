	mov.e r31, #3296			// Setup stack pointer

//
// Main
// args: 
//

// stack is []
// from :
_Main__:
	// decl `x`: u32
	// decl `place`: u32
	// assign r0 = `place`
	mov r0, #1				// expr `mov place, 1`
	// decl `chr`: u32
			

// expecting `r0` = `place`
// stack is [`x`, `place`, `chr`]
// from _Main__:
L3:
	ldw.e r1, r31, #2048				// assign r1 = `chr`
	ult.e r1, #54				// expr `ult chr, 54`
	c.jmp L5:				// expr `c.jmp L5:`

// expecting `r0` = `place`
// expecting `r1` = `chr`
// stack is [`x`, `place`, `chr`]
// from L3:
_L8:
	jmp L7:				// expr `jmp L7:`

// expecting `r0` = `place`
// expecting `r1` = `chr`
// stack is [`x`, `place`, `chr`]
// from _L8:
L7:
	ugt.e r1, #63				// expr `ugt chr, 63`
	// prepare state for L5:
	c.jmp L5:				// expr `c.jmp L5:`

// expecting `r0` = `place`
// expecting `r1` = `chr`
// stack is [`x`, `place`, `chr`]
// from L7:
_L10:
	jmp L6:				// expr `jmp L6:`

// expecting `r0` = `place`
// expecting `r1` = `chr`
// stack is [`x`, `place`, `chr`]
// from L3:
L5:
	jmp L2:				// expr `jmp L2:`

// expecting `r0` = `place`
// expecting `r1` = `chr`
// stack is [`x`, `place`, `chr`]
// from _L10:
L6:
	// decl `t13`: u32
	// assign r2 = `t13`
	sub.e r2, r1, #53				// expr `sub t13, chr, 53`
	// decl `temp`: u32
	// assign r3 = `temp`
	mov r3, r2				// expr `mov temp, t13`
	// undecl `t13`
	eq r3, #10				// expr `eq temp, 10`
	c.jmp L14:				// expr `c.jmp L14:`

// expecting `r0` = `place`
// expecting `r1` = `chr`
// expecting `r3` = `temp`
// stack is [`x`, `place`, `chr`, empty, `temp`]
// from L6:
_L16:
	jmp L15:				// expr `jmp L15:`

// expecting `r0` = `place`
// expecting `r1` = `chr`
// expecting `r3` = `temp`
// stack is [`x`, `place`, `chr`, empty, `temp`]
// from L6:
L14:
	mov r3, #0				// expr `mov temp, 0`
	// prepare state for L15:
			

// expecting `r0` = `place`
// expecting `r1` = `chr`
// expecting `r3` = `temp`
// stack is [`x`, `place`, `chr`, empty, `temp`]
// from _L16:
L15:
	// decl `t19`: u32
	// assign r2 = `t19`
	mul r2, r3, r0				// expr `mul t19, temp, place`
	// undecl `temp`
	ldw r3, r31, #0				// assign r3 = `x`
	add r3, r3, r2				// expr `add x, x, t19`
	// undecl `t19`
	mul r0, r0, #10				// expr `mul place, place, 10`
	// prepare state for L2:
	stw r3, r31, #0

// expecting `r0` = `place`
// expecting `r1` = `chr`
// stack is [`x`, `place`, `chr`]
// from L5:
L2:
	// decl `t20`: u32
	// assign r2 = `t20`
	ldkey r2				// expr `ldkey t20`
	mov r1, r2				// expr `mov chr, t20`
	// undecl `t20`
	ne.e r1, #51				// expr `ne chr, 51`
	// prepare state for L3:
	c.stw.e r1, r31, #2048
	c.jmp L3:				// expr `c.jmp L3:`

// expecting `r0` = `place`
// expecting `r1` = `chr`
// stack is [`x`, `place`, `chr`]
// from L2:
_L21:
	// undecl `place`
	// undecl `chr`
	jmp L4:				// expr `jmp L4:`

// stack is [`x`]
// from _L21:
L4:
	ldw r0, r31, #0				// assign r0 = `x`	// expr `argst 0, x`
	// undecl `x`
	add.e r31, r31, #128
	call _Fac__:
	sub.e r31, r31, #128				// expr `call Fac`
	// decl `t24`: u32
	// expr `retld t24, 0`
	// decl `fac`: u32
	// assign r1 = `fac`
	mov r1, r0				// expr `mov fac, t24`
	// undecl `t24`
	mov r0, r1				// assign r0 = `fac`	// expr `argst 0, fac`
	// undecl `fac`
	add.e r31, r31, #224
	call _BCD__:
	sub.e r31, r31, #224				// expr `call BCD`
	// decl `t25`: u32
	// expr `retld t25, 0`
	// decl `bcd`: u32
	// assign r1 = `bcd`
	mov r1, r0				// expr `mov bcd, t25`
	// undecl `t25`
	// decl `idx`: u32
	// assign r0 = `idx`
	mov r0, #0				// expr `mov idx, 0`
	// decl `t30`: u32
	// assign r2 = `t30`
	log r2, r1				// expr `log t30, bcd`
	// decl `t31`: u32
	// assign r3 = `t31`
	andn r3, r2, #3				// expr `andn t31, t30, 3`
	// undecl `t30`
	// decl `t32`: u32
	// assign r2 = `t32`
	mov r2, r3				// expr `mov t32, t31`
	// undecl `t31`
	// decl `nibble`: u32
	// assign r3 = `nibble`
	mov r3, r2				// expr `mov nibble, t32`
	// undecl `t32`
			

// expecting `r0` = `idx`
// expecting `r1` = `bcd`
// expecting `r3` = `nibble`
// stack is [`bcd`, `idx`, empty, `nibble`]
// from L4:
L27:
	sge r3, #0				// expr `sge nibble, 0`
	c.jmp L28:				// expr `c.jmp L28:`

// expecting `r0` = `idx`
// expecting `r1` = `bcd`
// expecting `r3` = `nibble`
// stack is [`bcd`, `idx`, empty, `nibble`]
// from L27:
_L33:
	// undecl `idx`
	// undecl `bcd`
	// undecl `nibble`
	jmp L29:				// expr `jmp L29:`

// expecting `r0` = `idx`
// expecting `r1` = `bcd`
// expecting `r3` = `nibble`
// stack is [`bcd`, `idx`, empty, `nibble`]
// from L27:
L28:
	// decl `t35`: u32
	// assign r2 = `t35`
	bsf r2, r1, r3, #4				// expr `bsf t35, bcd, nibble, 4`
	// decl `t36`: u32
	// assign r4 = `t36`
	and r4, r2, #15				// expr `and t36, t35, 15`
	// undecl `t35`
	// decl `t37`: u32
	// assign r2 = `t37`
	add.e r2, r4, #48				// expr `add t37, t36, 48`
	// undecl `t36`
	stchr.e r2, r0, #4294967295, #0				// expr `stchr t37, idx, 4294967295, 0`
	// undecl `t37`
	add r0, r0, #1				// expr `add idx, idx, 1`
	sub r3, r3, #4				// expr `sub nibble, nibble, 4`
	// prepare state for L27:
	jmp L27:				// expr `jmp L27:`

// stack is []
// from _L33:
L29:

// stack is []
// from L29:
L39:
	jmp L40:				// expr `jmp L40:`

// stack is []
// from L39:
L40:
	// prepare state for L39:
	jmp L39:				// expr `jmp L39:`

//
// Fac
// args: n_0
//

// stack is []
// from L4:
_Fac__:
	// expr `argld n, 0`
	eq r0, #1				// expr `eq n, 1`
	c.jmp L44:				// expr `c.jmp L44:`

// expecting `r0` = `n`
// stack is [`n`]
// from _Fac__:
_L46:
	jmp L45:				// expr `jmp L45:`

// expecting `r0` = `n`
// stack is [`n`]
// from _Fac__:
L44:
	// undecl `n`
	mov r0, #1				// expr `retst 0, 1`
	ret 				// expr `ret `

// expecting `r0` = `n`
// stack is [`n`]
// from _L46:
L45:
	// decl `t49`: u32
	// assign r1 = `t49`
	sub r1, r0, #1				// expr `sub t49, n, 1`
	stw r0, r31, #0				// clobbering r0 (`n`)
	mov r0, r1				// assign r0 = `t49`	// expr `argst 0, t49`
	// undecl `t49`
	add.e r31, r31, #64
	call _Fac__:
	sub.e r31, r31, #64				// expr `call Fac`
	// decl `t50`: u32
	// expr `retld t50, 0`
	// decl `t51`: u32
	// assign r1 = `t51`
	ldw r2, r31, #0				// assign r2 = `n`
	mul r1, r2, r0				// expr `mul t51, n, t50`
	// undecl `t50`
	// undecl `n`
	mov r0, r1				// assign r0 = `t51`	// expr `retst 0, t51`
	// undecl `t51`
	ret 				// expr `ret `

//
// BCD
// args: x_0
//

// stack is []
// from L4:
_BCD__:
	// expr `argld x, 0`
	// decl `y`: u32
	// assign r1 = `y`
	mov r1, #0				// expr `mov y, 0`
	// decl `_`: u32
	// assign r2 = `_`
	mov r2, #0				// expr `mov _, 0`

// expecting `r0` = `x`
// expecting `r1` = `y`
// expecting `r2` = `_`
// stack is [`x`, `y`, `_`]
// from _BCD__:
L54:
	ult.e r2, #32				// expr `ult _, 32`
	c.jmp L55:				// expr `c.jmp L55:`

// expecting `r0` = `x`
// expecting `r1` = `y`
// expecting `r2` = `_`
// stack is [`x`, `y`, `_`]
// from L54:
_L58:
	// undecl `x`
	// undecl `_`
	jmp L56:				// expr `jmp L56:`

// expecting `r0` = `x`
// expecting `r1` = `y`
// expecting `r2` = `_`
// stack is [`x`, `y`, `_`]
// from L54:
L55:
	// decl `t60`: u32
	// assign r3 = `t60`
	dab r3, r1				// expr `dab t60, y`
	mov r1, r3				// expr `mov y, t60`
	// undecl `t60`
	bsl r1, r1, #1				// expr `bsl y, y, 1`
	// decl `t64`: u32
	// assign r3 = `t64`
	and.e r3, r0, #2147483648				// expr `and t64, x, 2147483648`
	eq r3, #0				// expr `eq t64, 0`
	// undecl `t64`
	c.jmp L62:				// expr `c.jmp L62:`

// expecting `r0` = `x`
// expecting `r1` = `y`
// expecting `r2` = `_`
// stack is [`x`, `y`, `_`]
// from L55:
_L65:

// expecting `r0` = `x`
// expecting `r1` = `y`
// expecting `r2` = `_`
// stack is [`x`, `y`, `_`]
// from _L65:
L61:
	or r1, r1, #1				// expr `or y, y, 1`
	// prepare state for L62:
			

// expecting `r0` = `x`
// expecting `r1` = `y`
// expecting `r2` = `_`
// stack is [`x`, `y`, `_`]
// from L55:
L62:
	bsl r0, r0, #1				// expr `bsl x, x, 1`
	add r2, r2, #1				// expr `add _, _, 1`
	// prepare state for L54:
	jmp L54:				// expr `jmp L54:`

// expecting `r1` = `y`
// stack is [empty, `y`]
// from _L58:
L56:
	mov r0, r1				// assign r0 = `y`	// expr `retst 0, y`
	// undecl `y`
	ret 				// expr `ret `
