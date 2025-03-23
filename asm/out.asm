.DATA


.CODE
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
	mov r3, #0				// expr `mov u_temp, 0`
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
	ldw r3, r31, #0				// assign r3 = `x`
	add r3, r3, r2				// expr `add x, x, t17`
	// undecl `t17`
	mul r0, r0, #10				// expr `mul place, place, 10`
	// prepare state for L1:
	stw r3, r31, #0

// expecting `r0` = `place`
// expecting `r1` = `chr`
// stack is [`x`, `place`, `chr`]
// from L4:
L1:
	// decl `t18`: u32
	// assign r2 = `t18`
	ldkey r2				// expr `ldkey t18`
	mov r1, r2				// expr `mov chr, t18`
	// undecl `t18`
	ne.e r1, #51				// expr `ne chr, 51`
	// prepare state for L2:
	c.stw.e r1, r31, #64
	c.jmp L2:				// expr `c.jmp L2:`

// expecting `r0` = `place`
// expecting `r1` = `chr`
// stack is [`x`, `place`, `chr`]
// from L1:
_L19:
	// undecl `place`
	// undecl `chr`
	jmp L3:				// expr `jmp L3:`

// stack is [`x`]
// from _L19:
L3:
	ldw r0, r31, #0				// assign r0 = `x`	// expr `argst 0, x`
	// undecl `x`
	add.e r31, r31, #128
	call _Fac__:
	sub.e r31, r31, #128				// expr `call Fac`
	// decl `t22`: u32
	// expr `retld t22, 0`
	// expr `argst 0, t22`
	// undecl `t22`
	add.e r31, r31, #192
	call _Print__:
	sub.e r31, r31, #192				// expr `call Print`
	// expr `retld t23, 0`

// expecting `r0` = `t23`
// stack is [`t23`]
// from L3:
L24:
	jmp L25:				// expr `jmp L25:`

// expecting `r0` = `t23`
// stack is [`t23`]
// from L24:
L25:
	// prepare state for L24:
	jmp L24:				// expr `jmp L24:`

//
// Fac
// args: n
//

// stack is []
// from L3:
_Fac__:
	// expr `argld n, 0`
	eq r0, #1				// expr `eq n, 1`
	c.jmp L29:				// expr `c.jmp L29:`

// expecting `r0` = `n`
// stack is [`n`]
// from _Fac__:
_L31:
	jmp L30:				// expr `jmp L30:`

// expecting `r0` = `n`
// stack is [`n`]
// from _Fac__:
L29:
	// undecl `n`
	mov r0, #1				// expr `retst 0, 1`
	ret 				// expr `ret`

// expecting `r0` = `n`
// stack is [`n`]
// from _L31:
L30:
	// decl `t34`: u32
	// assign r1 = `t34`
	sub r1, r0, #1				// expr `sub t34, n, 1`
	stw r0, r31, #0				// clobbering r0 (`n`)
	mov r0, r1				// assign r0 = `t34`	// expr `argst 0, t34`
	// undecl `t34`
	add.e r31, r31, #64
	call _Fac__:
	sub.e r31, r31, #64				// expr `call Fac`
	// decl `t35`: u32
	// expr `retld t35, 0`
	// decl `t36`: u32
	// assign r1 = `t36`
	ldw r2, r31, #0				// assign r2 = `n`
	mul r1, r2, r0				// expr `mul t36, n, t35`
	// undecl `t35`
	// undecl `n`
	mov r0, r1				// assign r0 = `t36`	// expr `retst 0, t36`
	// undecl `t36`
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
	mov r1, #0				// expr `mov bcd, 0`
	// decl `u___`: u32
	// assign r2 = `u___`
	mov r2, #0				// expr `mov u___, 0`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `u___`
// stack is [`x`, `bcd`, `u___`]
// from _Print__:
L38:
	ult.e r2, #32				// expr `ult u___, 32`
	c.jmp L39:				// expr `c.jmp L39:`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `u___`
// stack is [`x`, `bcd`, `u___`]
// from L38:
_L41:
	// undecl `x`
	// undecl `u___`
	jmp L40:				// expr `jmp L40:`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `u___`
// stack is [`x`, `bcd`, `u___`]
// from L38:
L39:
	// decl `t43`: u32
	// assign r3 = `t43`
	dab r3, r1				// expr `dab t43, bcd`
	mov r1, r3				// expr `mov bcd, t43`
	// undecl `t43`
	bsl r1, r1, #1				// expr `bsl bcd, bcd, 1`
	// decl `t47`: u32
	// assign r3 = `t47`
	and.e r3, r0, #2147483648				// expr `and t47, x, 2147483648`
	eq r3, #0				// expr `eq t47, 0`
	// undecl `t47`
	c.jmp L45:				// expr `c.jmp L45:`

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `u___`
// stack is [`x`, `bcd`, `u___`]
// from L39:
_L48:

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `u___`
// stack is [`x`, `bcd`, `u___`]
// from _L48:
L44:
	or r1, r1, #1				// expr `or bcd, bcd, 1`
	// prepare state for L45:

// expecting `r0` = `x`
// expecting `r1` = `bcd`
// expecting `r2` = `u___`
// stack is [`x`, `bcd`, `u___`]
// from L39:
L45:
	bsl r0, r0, #1				// expr `bsl x, x, 1`
	add r2, r2, #1				// expr `add u___, u___, 1`
	// prepare state for L38:
	jmp L38:				// expr `jmp L38:`

// expecting `r1` = `bcd`
// stack is [empty, `bcd`]
// from _L41:
L40:
	// decl `idx`: u32
	// assign r0 = `idx`
	mov r0, #0				// expr `mov idx, 0`
	// decl `t53`: u32
	// assign r2 = `t53`
	log r2, r1				// expr `log t53, bcd`
	// decl `t54`: u32
	// assign r3 = `t54`
	andn r3, r2, #3				// expr `andn t54, t53, 3`
	// undecl `t53`
	// decl `t55`: u32
	// assign r2 = `t55`
	mov r2, r3				// expr `mov t55, t54`
	// undecl `t54`
	// decl `nibble`: u32
	// assign r3 = `nibble`
	mov r3, r2				// expr `mov nibble, t55`
	// undecl `t55`

// expecting `r0` = `idx`
// expecting `r1` = `bcd`
// expecting `r3` = `nibble`
// stack is [`idx`, `bcd`, empty, `nibble`]
// from L40:
L50:
	sge r3, #0				// expr `sge nibble, 0`
	c.jmp L51:				// expr `c.jmp L51:`

// expecting `r0` = `idx`
// expecting `r1` = `bcd`
// expecting `r3` = `nibble`
// stack is [`idx`, `bcd`, empty, `nibble`]
// from L50:
_L56:
	// undecl `idx`
	// undecl `bcd`
	// undecl `nibble`
	jmp L52:				// expr `jmp L52:`

// expecting `r0` = `idx`
// expecting `r1` = `bcd`
// expecting `r3` = `nibble`
// stack is [`idx`, `bcd`, empty, `nibble`]
// from L50:
L51:
	// decl `t58`: u32
	// assign r2 = `t58`
	bsf r2, r1, r3, #4				// expr `bsf t58, bcd, nibble, 4`
	// decl `t59`: u32
	// assign r4 = `t59`
	and r4, r2, #15				// expr `and t59, t58, 15`
	// undecl `t58`
	// decl `t60`: u32
	// assign r2 = `t60`
	add.e r2, r4, #48				// expr `add t60, t59, 48`
	// undecl `t59`
	stchr.e r2, r0, #4294967295, #0				// expr `stchr t60, idx, 4294967295, 0`
	// undecl `t60`
	add r0, r0, #1				// expr `add idx, idx, 1`
	sub r3, r3, #4				// expr `sub nibble, nibble, 4`
	// prepare state for L50:
	jmp L50:				// expr `jmp L50:`

// stack is []
// from _L56:
L52:

    