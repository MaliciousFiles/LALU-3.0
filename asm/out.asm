.DATA


.CODE
	mov.e r31, #3552			// Setup stack pointer

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
L2:
	ldw.e r1, r31, #64				// assign r1 = `chr`
	ult.e r1, #54				// expr `ult chr, 54`
	c.jmp L4:				// expr `c.jmp L4:`

// expecting `r0` = `place`
// expecting `r1` = `chr`
// stack is [`x`, `place`, `chr`]
// from L2:
_L7:
	jmp L6:				// expr `jmp L6:`

// expecting `r0` = `place`
// expecting `r1` = `chr`
// stack is [`x`, `place`, `chr`]
// from _L7:
L6:
	ugt.e r1, #63				// expr `ugt chr, 63`
	// prepare state for L4:
	c.jmp L4:				// expr `c.jmp L4:`

// expecting `r0` = `place`
// expecting `r1` = `chr`
// stack is [`x`, `place`, `chr`]
// from L6:
_L9:
	jmp L5:				// expr `jmp L5:`

// expecting `r0` = `place`
// expecting `r1` = `chr`
// stack is [`x`, `place`, `chr`]
// from L2:
L4:
	jmp L1:				// expr `jmp L1:`

// expecting `r0` = `place`
// expecting `r1` = `chr`
// stack is [`x`, `place`, `chr`]
// from _L9:
L5:
	// decl `t12`: u32
	// assign r2 = `t12`
	sub.e r2, r1, #53				// expr `sub t12, chr, 53`
	// decl `u_temp`: u32
	// assign r3 = `u_temp`
	mov r3, r2				// expr `mov u_temp, t12`
	// undecl `t12`
	eq r3, #10				// expr `eq u_temp, 10`
	c.jmp L13:				// expr `c.jmp L13:`

// expecting `r0` = `place`
// expecting `r1` = `chr`
// expecting `r3` = `u_temp`
// stack is [`x`, `place`, `chr`, empty, `u_temp`]
// from L5:
_L15:
	jmp L14:				// expr `jmp L14:`

// expecting `r0` = `place`
// expecting `r1` = `chr`
// expecting `r3` = `u_temp`
// stack is [`x`, `place`, `chr`, empty, `u_temp`]
// from L5:
L13:
	mov r30, #0
	mov r3, r30				// expr `mov u_temp, 0`
	// prepare state for L14:

// expecting `r0` = `place`
// expecting `r1` = `chr`
// expecting `r3` = `u_temp`
// stack is [`x`, `place`, `chr`, empty, `u_temp`]
// from _L15:
L14:
	// decl `t17`: u32
	// assign r2 = `t17`
	mul r2, r3, r0				// expr `mul t17, u_temp, place`
	// undecl `u_temp`
	// decl `t18`: u32
	// assign r3 = `t18`
	ldw r4, r31, #0				// assign r4 = `x`
	add r3, r4, r2				// expr `add t18, x, t17`
	// undecl `t17`
	mov r4, r3				// expr `mov x, t18`
	// undecl `t18`
	// decl `t19`: u32
	// assign r2 = `t19`
	mul r2, r0, #10				// expr `mul t19, place, 10`
	mov r0, r2				// expr `mov place, t19`
	// undecl `t19`
	// prepare state for L1:
	stw r4, r31, #0

// expecting `r0` = `place`
// expecting `r1` = `chr`
// stack is [`x`, `place`, `chr`]
// from L4:
L1:
	// decl `t20`: u32
	// assign r2 = `t20`
	ldkey r2				// expr `ldkey t20`
	mov r1, r2				// expr `mov chr, t20`
	// undecl `t20`
	ne.e r1, #51				// expr `ne chr, 51`
	// prepare state for L2:
	c.stw.e r1, r31, #64
	c.jmp L2:				// expr `c.jmp L2:`

// expecting `r0` = `place`
// expecting `r1` = `chr`
// stack is [`x`, `place`, `chr`]
// from L1:
_L21:
	// undecl `place`
	// undecl `chr`
	jmp L3:				// expr `jmp L3:`

// stack is [`x`]
// from _L21:
L3:
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
// from L3:
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
// args: n
//

// stack is []
// from L3:
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
	ret 				// expr `ret`

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
	ret 				// expr `ret`

//
// Print
// args: x
//

// stack is []
// from L3:
_Print__:
	// expr `argld x, 0`
	// decl `bcd`: u32
	// assign r1 = `bcd`
	mov r30, #0
	mov r1, r30				// expr `mov bcd, 0`
	// decl `u___`: u32
	// assign r2 = `u___`
	mov r30, #0
	mov r2, r30				// expr `mov u___, 0`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `u___`
// stack is [`x`, `bcd`, `u___`]
// from _Print__:
L40:
	ult.e r2, #32				// expr `ult u___, 32`
	c.jmp L41:				// expr `c.jmp L41:`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `u___`
// stack is [`x`, `bcd`, `u___`]
// from L40:
_L43:
	// undecl `x`
	// undecl `u___`
	jmp L42:				// expr `jmp L42:`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `u___`
// stack is [`x`, `bcd`, `u___`]
// from L40:
L41:
	// decl `t45`: u32
	// assign r3 = `t45`
	dab r3, r1				// expr `dab t45, bcd`
	mov r1, r3				// expr `mov bcd, t45`
	// undecl `t45`
	// decl `t46`: u32
	// assign r3 = `t46`
	bsl r3, r1, #1				// expr `bsl t46, bcd, 1`
	mov r1, r3				// expr `mov bcd, t46`
	// undecl `t46`
	// decl `t50`: u32
	// assign r3 = `t50`
	and.e r3, r0, #2147483648				// expr `and t50, x, 2147483648`
	eq r3, #0				// expr `eq t50, 0`
	// undecl `t50`
	c.jmp L48:				// expr `c.jmp L48:`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `u___`
// stack is [`x`, `bcd`, `u___`]
// from L41:
_L51:

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `u___`
// stack is [`x`, `bcd`, `u___`]
// from _L51:
L47:
	// decl `t52`: u32
	// assign r3 = `t52`
	or r3, r1, #1				// expr `or t52, bcd, 1`
	mov r1, r3				// expr `mov bcd, t52`
	// undecl `t52`
	// prepare state for L48:

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `u___`
// stack is [`x`, `bcd`, `u___`]
// from L41:
L48:
	// decl `t53`: u32
	// assign r3 = `t53`
	bsl r3, r0, #1				// expr `bsl t53, x, 1`
	mov r0, r3				// expr `mov x, t53`
	// undecl `t53`
	// decl `t54`: u32
	// assign r3 = `t54`
	add r3, r2, #1				// expr `add t54, u___, 1`
	mov r2, r3				// expr `mov u___, t54`
	// undecl `t54`
	// prepare state for L40:
	jmp L40:				// expr `jmp L40:`

// expecting `r1` = `bcd`
// stack is [empty, `bcd`]
// from _L43:
L42:
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
// from L42:
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
	// decl `t67`: u32
	// assign r2 = `t67`
	add r2, r0, #1				// expr `add t67, idx, 1`
	mov r0, r2				// expr `mov idx, t67`
	// undecl `t67`
	// decl `t68`: u32
	// assign r2 = `t68`
	sub r2, r3, #4				// expr `sub t68, nibble, 4`
	mov r3, r2				// expr `mov nibble, t68`
	// undecl `t68`
	// prepare state for L56:
	jmp L56:				// expr `jmp L56:`

// stack is []
// from _L62:
L58:

    