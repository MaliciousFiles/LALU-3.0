	mov.e r31, #3136			// Setup stack pointer

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
	// expr `argst 0, t24`
	// undecl `t24`
	add.e r31, r31, #192
	call _Print__:
	sub.e r31, r31, #192				// expr `call Print`
	// expr `retld t25, 0`
			

// expecting `r0` = `t25`
// stack is [`t25`]
// from L4:
L26:
	jmp L27:				// expr `jmp L27:`

// expecting `r0` = `t25`
// stack is [`t25`]
// from L26:
L27:
	// prepare state for L26:
	jmp L26:				// expr `jmp L26:`

//
// Fac
// args: n_0
//

// stack is []
// from L4:
_Fac__:
	// expr `argld n, 0`
	eq r0, #1				// expr `eq n, 1`
	c.jmp L31:				// expr `c.jmp L31:`

// expecting `r0` = `n`
// stack is [`n`]
// from _Fac__:
_L33:
	jmp L32:				// expr `jmp L32:`

// expecting `r0` = `n`
// stack is [`n`]
// from _Fac__:
L31:
	// undecl `n`
	mov r0, #1				// expr `retst 0, 1`
	ret 				// expr `ret `

// expecting `r0` = `n`
// stack is [`n`]
// from _L33:
L32:
	// decl `t36`: u32
	// assign r1 = `t36`
	sub r1, r0, #1				// expr `sub t36, n, 1`
	stw r0, r31, #0				// clobbering r0 (`n`)
	mov r0, r1				// assign r0 = `t36`	// expr `argst 0, t36`
	// undecl `t36`
	add.e r31, r31, #64
	call _Fac__:
	sub.e r31, r31, #64				// expr `call Fac`
	// decl `t37`: u32
	// expr `retld t37, 0`
	// decl `t38`: u32
	// assign r1 = `t38`
	ldw r2, r31, #0				// assign r2 = `n`
	mul r1, r2, r0				// expr `mul t38, n, t37`
	// undecl `t37`
	// undecl `n`
	mov r0, r1				// assign r0 = `t38`	// expr `retst 0, t38`
	// undecl `t38`
	ret 				// expr `ret `

//
// Print
// args: x_0
//

// stack is []
// from L4:
_Print__:
	// expr `argld x, 0`
	// decl `bcd`: u32
	// assign r1 = `bcd`
	mov r1, #0				// expr `mov bcd, 0`
	// decl `_`: u32
	// assign r2 = `_`
	mov r2, #0				// expr `mov _, 0`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `_`
// stack is [`x`, `bcd`, `_`]
// from _Print__:
L41:
	ult.e r2, #32				// expr `ult _, 32`
	c.jmp L42:				// expr `c.jmp L42:`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `_`
// stack is [`x`, `bcd`, `_`]
// from L41:
_L45:
	// undecl `x`
	// undecl `_`
	jmp L43:				// expr `jmp L43:`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `_`
// stack is [`x`, `bcd`, `_`]
// from L41:
L42:
	// decl `t47`: u32
	// assign r3 = `t47`
	dab r3, r1				// expr `dab t47, bcd`
	mov r1, r3				// expr `mov bcd, t47`
	// undecl `t47`
	bsl r1, r1, #1				// expr `bsl bcd, bcd, 1`
	// decl `t51`: u32
	// assign r3 = `t51`
	and.e r3, r0, #2147483648				// expr `and t51, x, 2147483648`
	eq r3, #0				// expr `eq t51, 0`
	// undecl `t51`
	c.jmp L49:				// expr `c.jmp L49:`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `_`
// stack is [`x`, `bcd`, `_`]
// from L42:
_L52:

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `_`
// stack is [`x`, `bcd`, `_`]
// from _L52:
L48:
	or r1, r1, #1				// expr `or bcd, bcd, 1`
	// prepare state for L49:
			

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `_`
// stack is [`x`, `bcd`, `_`]
// from L42:
L49:
	bsl r0, r0, #1				// expr `bsl x, x, 1`
	add r2, r2, #1				// expr `add _, _, 1`
	// prepare state for L41:
	jmp L41:				// expr `jmp L41:`

// expecting `r1` = `bcd`
// stack is [empty, `bcd`]
// from _L45:
L43:
	// decl `idx`: u32
	// assign r0 = `idx`
	mov r0, #0				// expr `mov idx, 0`
	// decl `t58`: u32
	// assign r2 = `t58`
	log r2, r1				// expr `log t58, bcd`
	// decl `t59`: u32
	// assign r3 = `t59`
	andn r3, r2, #3				// expr `andn t59, t58, 3`
	// undecl `t58`
	// decl `t60`: u32
	// assign r2 = `t60`
	mov r2, r3				// expr `mov t60, t59`
	// undecl `t59`
	// decl `nibble`: u32
	// assign r3 = `nibble`
	mov r3, r2				// expr `mov nibble, t60`
	// undecl `t60`
			

// expecting `r0` = `idx`
// expecting `r1` = `bcd`
// expecting `r3` = `nibble`
// stack is [`idx`, `bcd`, empty, `nibble`]
// from L43:
L55:
	sge r3, #0				// expr `sge nibble, 0`
	c.jmp L56:				// expr `c.jmp L56:`

// expecting `r0` = `idx`
// expecting `r1` = `bcd`
// expecting `r3` = `nibble`
// stack is [`idx`, `bcd`, empty, `nibble`]
// from L55:
_L61:
	// undecl `idx`
	// undecl `bcd`
	// undecl `nibble`
	jmp L57:				// expr `jmp L57:`

// expecting `r0` = `idx`
// expecting `r1` = `bcd`
// expecting `r3` = `nibble`
// stack is [`idx`, `bcd`, empty, `nibble`]
// from L55:
L56:
	// decl `t63`: u32
	// assign r2 = `t63`
	bsf r2, r1, r3, #4				// expr `bsf t63, bcd, nibble, 4`
	// decl `t64`: u32
	// assign r4 = `t64`
	and r4, r2, #15				// expr `and t64, t63, 15`
	// undecl `t63`
	// decl `t65`: u32
	// assign r2 = `t65`
	add.e r2, r4, #48				// expr `add t65, t64, 48`
	// undecl `t64`
	stchr.e r2, r0, #4294967295, #0				// expr `stchr t65, idx, 4294967295, 0`
	// undecl `t65`
	add r0, r0, #1				// expr `add idx, idx, 1`
	sub r3, r3, #4				// expr `sub nibble, nibble, 4`
	// prepare state for L55:
	jmp L55:				// expr `jmp L55:`

// stack is []
// from _L61:
L57:
