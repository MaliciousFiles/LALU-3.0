.DATA


.CODE
	mov.e r31, #3328			// Setup stack pointer

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
	mov r30, #1
	mov r0, r30				// expr `mov place, 1`
	// decl `chr`: u32

// expecting `r0` = `place`
// stack is [`x`, `place`, `chr`]
// from _Main__:
L3:
	ldw.e r1, r31, #64				// assign r1 = `chr`
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
	mov r30, #0
	mov r3, r30				// expr `mov temp, 0`
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
	c.stw.e r1, r31, #64
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
	breakpoint 				// expr `breakpoint`
	ldw r0, r31, #0				// assign r0 = `x`	// expr `argst 0, x`
	// undecl `x`
	add.e r31, r31, #128
	call _Fac__:
	sub.e r31, r31, #128				// expr `call Fac`
	// decl `t25`: u32
	// expr `retld t25, 0`
	// expr `argst 0, t25`
	// undecl `t25`
	add.e r31, r31, #192
	call _Print__:
	sub.e r31, r31, #192				// expr `call Print`
	// expr `retld t26, 0`

// expecting `r0` = `t26`
// stack is [`t26`]
// from L4:
L27:
	jmp L28:				// expr `jmp L28:`

// expecting `r0` = `t26`
// stack is [`t26`]
// from L27:
L28:
	// prepare state for L27:
	jmp L27:				// expr `jmp L27:`

//
// Fac
// args: n_0
//

// stack is []
// from L4:
_Fac__:
	// expr `argld n, 0`
	eq r0, #1				// expr `eq n, 1`
	c.jmp L32:				// expr `c.jmp L32:`

// expecting `r0` = `n`
// stack is [`n`]
// from _Fac__:
_L34:
	jmp L33:				// expr `jmp L33:`

// expecting `r0` = `n`
// stack is [`n`]
// from _Fac__:
L32:
	// undecl `n`
	mov r0, #1				// expr `retst 0, 1`
	ret 				// expr `ret`

// expecting `r0` = `n`
// stack is [`n`]
// from _L34:
L33:
	// decl `t37`: u32
	// assign r1 = `t37`
	sub r1, r0, #1				// expr `sub t37, n, 1`
	stw r0, r31, #0				// clobbering r0 (`n`)
	mov r0, r1				// assign r0 = `t37`	// expr `argst 0, t37`
	// undecl `t37`
	add.e r31, r31, #64
	call _Fac__:
	sub.e r31, r31, #64				// expr `call Fac`
	// decl `t38`: u32
	// expr `retld t38, 0`
	// decl `t39`: u32
	// assign r1 = `t39`
	ldw r2, r31, #0				// assign r2 = `n`
	mul r1, r2, r0				// expr `mul t39, n, t38`
	// undecl `t38`
	// undecl `n`
	mov r0, r1				// assign r0 = `t39`	// expr `retst 0, t39`
	// undecl `t39`
	ret 				// expr `ret`

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
	mov r30, #0
	mov r1, r30				// expr `mov bcd, 0`
	// decl `_`: u32
	// assign r2 = `_`
	mov r30, #0
	mov r2, r30				// expr `mov _, 0`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `_`
// stack is [`x`, `bcd`, `_`]
// from _Print__:
L42:
	ult.e r2, #32				// expr `ult _, 32`
	c.jmp L43:				// expr `c.jmp L43:`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `_`
// stack is [`x`, `bcd`, `_`]
// from L42:
_L46:
	// undecl `x`
	// undecl `_`
	jmp L44:				// expr `jmp L44:`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `_`
// stack is [`x`, `bcd`, `_`]
// from L42:
L43:
	// decl `t48`: u32
	// assign r3 = `t48`
	dab r3, r1				// expr `dab t48, bcd`
	mov r1, r3				// expr `mov bcd, t48`
	// undecl `t48`
	bsl r1, r1, #1				// expr `bsl bcd, bcd, 1`
	// decl `t52`: u32
	// assign r3 = `t52`
	and.e r3, r0, #2147483648				// expr `and t52, x, 2147483648`
	eq r3, #0				// expr `eq t52, 0`
	// undecl `t52`
	c.jmp L50:				// expr `c.jmp L50:`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `_`
// stack is [`x`, `bcd`, `_`]
// from L43:
_L53:

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `_`
// stack is [`x`, `bcd`, `_`]
// from _L53:
L49:
	or r1, r1, #1				// expr `or bcd, bcd, 1`
	// prepare state for L50:

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `_`
// stack is [`x`, `bcd`, `_`]
// from L43:
L50:
	bsl r0, r0, #1				// expr `bsl x, x, 1`
	add r2, r2, #1				// expr `add _, _, 1`
	// prepare state for L42:
	jmp L42:				// expr `jmp L42:`

// expecting `r1` = `bcd`
// stack is [empty, `bcd`]
// from _L46:
L44:
	// decl `idx`: u32
	// assign r0 = `idx`
	mov r30, #0
	mov r0, r30				// expr `mov idx, 0`
	// decl `t59`: u32
	// assign r2 = `t59`
	log r2, r1				// expr `log t59, bcd`
	// decl `t60`: u32
	// assign r3 = `t60`
	andn r3, r2, #3				// expr `andn t60, t59, 3`
	// undecl `t59`
	// decl `t61`: u32
	// assign r2 = `t61`
	mov r2, r3				// expr `mov t61, t60`
	// undecl `t60`
	// decl `nibble`: u32
	// assign r3 = `nibble`
	mov r3, r2				// expr `mov nibble, t61`
	// undecl `t61`

// expecting `r0` = `idx`
// expecting `r1` = `bcd`
// expecting `r3` = `nibble`
// stack is [`idx`, `bcd`, empty, `nibble`]
// from L44:
L56:
	sge r3, #0				// expr `sge nibble, 0`
	c.jmp L57:				// expr `c.jmp L57:`

// expecting `r0` = `idx`
// expecting `r1` = `bcd`
// expecting `r3` = `nibble`
// stack is [`idx`, `bcd`, empty, `nibble`]
// from L56:
_L62:
	// undecl `idx`
	// undecl `bcd`
	// undecl `nibble`
	jmp L58:				// expr `jmp L58:`

// expecting `r0` = `idx`
// expecting `r1` = `bcd`
// expecting `r3` = `nibble`
// stack is [`idx`, `bcd`, empty, `nibble`]
// from L56:
L57:
	// decl `t64`: u32
	// assign r2 = `t64`
	bsf r2, r1, r3, #4				// expr `bsf t64, bcd, nibble, 4`
	// decl `t65`: u32
	// assign r4 = `t65`
	and r4, r2, #15				// expr `and t65, t64, 15`
	// undecl `t64`
	// decl `t66`: u32
	// assign r2 = `t66`
	add.e r2, r4, #48				// expr `add t66, t65, 48`
	// undecl `t65`
	stchr.e r2, r0, #4294967295, #0				// expr `stchr t66, idx, 4294967295, 0`
	// undecl `t66`
	add r0, r0, #1				// expr `add idx, idx, 1`
	sub r3, r3, #4				// expr `sub nibble, nibble, 4`
	// prepare state for L56:
	jmp L56:				// expr `jmp L56:`

// stack is []
// from _L62:
L58:

    