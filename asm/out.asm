.DATA


.CODE
	mov.e r31, #3584			// Setup stack pointer

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
// from L3:
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
// args: n
//

// stack is []
// from L3:
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
L41:
	ult.e r2, #32				// expr `ult u___, 32`
	c.jmp L42:				// expr `c.jmp L42:`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `u___`
// stack is [`x`, `bcd`, `u___`]
// from L41:
_L44:
	// undecl `x`
	// undecl `u___`
	jmp L43:				// expr `jmp L43:`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `u___`
// stack is [`x`, `bcd`, `u___`]
// from L41:
L42:
	// decl `t46`: u32
	// assign r3 = `t46`
	dab r3, r1				// expr `dab t46, bcd`
	mov r1, r3				// expr `mov bcd, t46`
	// undecl `t46`
	// decl `t47`: u32
	// assign r3 = `t47`
	bsl r3, r1, #1				// expr `bsl t47, bcd, 1`
	mov r1, r3				// expr `mov bcd, t47`
	// undecl `t47`
	// decl `t51`: u32
	// assign r3 = `t51`
	and.e r3, r0, #2147483648				// expr `and t51, x, 2147483648`
	eq r3, #0				// expr `eq t51, 0`
	// undecl `t51`
	c.jmp L49:				// expr `c.jmp L49:`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `u___`
// stack is [`x`, `bcd`, `u___`]
// from L42:
_L52:

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `u___`
// stack is [`x`, `bcd`, `u___`]
// from _L52:
L48:
	// decl `t53`: u32
	// assign r3 = `t53`
	or r3, r1, #1				// expr `or t53, bcd, 1`
	mov r1, r3				// expr `mov bcd, t53`
	// undecl `t53`
	// prepare state for L49:

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `u___`
// stack is [`x`, `bcd`, `u___`]
// from L42:
L49:
	// decl `t54`: u32
	// assign r3 = `t54`
	bsl r3, r0, #1				// expr `bsl t54, x, 1`
	mov r0, r3				// expr `mov x, t54`
	// undecl `t54`
	// decl `t55`: u32
	// assign r3 = `t55`
	add r3, r2, #1				// expr `add t55, u___, 1`
	mov r2, r3				// expr `mov u___, t55`
	// undecl `t55`
	// prepare state for L41:
	jmp L41:				// expr `jmp L41:`

// expecting `r1` = `bcd`
// stack is [empty, `bcd`]
// from _L44:
L43:
	// decl `idx`: u32
	// assign r0 = `idx`
	mov r30, #0
	mov r0, r30				// expr `mov idx, 0`
	// decl `t60`: u32
	// assign r2 = `t60`
	log r2, r1				// expr `log t60, bcd`
	// decl `t61`: u32
	// assign r3 = `t61`
	andn r3, r2, #3				// expr `andn t61, t60, 3`
	// undecl `t60`
	// decl `t62`: u32
	// assign r2 = `t62`
	mov r2, r3				// expr `mov t62, t61`
	// undecl `t61`
	// decl `nibble`: u32
	// assign r3 = `nibble`
	mov r3, r2				// expr `mov nibble, t62`
	// undecl `t62`

// expecting `r0` = `idx`
// expecting `r1` = `bcd`
// expecting `r3` = `nibble`
// stack is [`idx`, `bcd`, empty, `nibble`]
// from L43:
L57:
	sge r3, #0				// expr `sge nibble, 0`
	c.jmp L58:				// expr `c.jmp L58:`

// expecting `r0` = `idx`
// expecting `r1` = `bcd`
// expecting `r3` = `nibble`
// stack is [`idx`, `bcd`, empty, `nibble`]
// from L57:
_L63:
	// undecl `idx`
	// undecl `bcd`
	// undecl `nibble`
	jmp L59:				// expr `jmp L59:`

// expecting `r0` = `idx`
// expecting `r1` = `bcd`
// expecting `r3` = `nibble`
// stack is [`idx`, `bcd`, empty, `nibble`]
// from L57:
L58:
	// decl `t65`: u32
	// assign r2 = `t65`
	bsf r2, r1, r3, #4				// expr `bsf t65, bcd, nibble, 4`
	// decl `t66`: u32
	// assign r4 = `t66`
	and r4, r2, #15				// expr `and t66, t65, 15`
	// undecl `t65`
	// decl `t67`: u32
	// assign r2 = `t67`
	add.e r2, r4, #48				// expr `add t67, t66, 48`
	// undecl `t66`
	stchr.e r2, r0, #4294967295, #0				// expr `stchr t67, idx, 4294967295, 0`
	// undecl `t67`
	// decl `t68`: u32
	// assign r2 = `t68`
	add r2, r0, #1				// expr `add t68, idx, 1`
	mov r0, r2				// expr `mov idx, t68`
	// undecl `t68`
	// decl `t69`: u32
	// assign r2 = `t69`
	sub r2, r3, #4				// expr `sub t69, nibble, 4`
	mov r3, r2				// expr `mov nibble, t69`
	// undecl `t69`
	// prepare state for L57:
	jmp L57:				// expr `jmp L57:`

// stack is []
// from _L63:
L59:

    