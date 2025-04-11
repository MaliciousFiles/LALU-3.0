.DATA


.CODE
	mov.e r31, #1760			// Setup stack pointer

//
// Main
// args: 
//

// stack is []
// from :
_Main__:
	// decl `x`: u32
	mov r0, #7				// expr `argst 0, 7`
	add.e r31, r31, #32
	call _HSB__:
	sub.e r31, r31, #32				// expr `call HSB`
	// decl `t14`: u32
	// expr `retld t14, 0`
	// decl `magic`: u32
	// assign r1 = `magic`
	mov r1, r0				// expr `mov magic, t14`
	// undecl `t14`
	eq r1, #4				// expr `eq magic, 4`
	// undecl `magic`
	c.jmp L15:				// expr `c.jmp L15:`

// stack is [`x`]
// from _Main__:
_L17:
	jmp L16:				// expr `jmp L16:`

// stack is [`x`]
// from _Main__:
L15:
	ldw r0, r31, #0				// assign r0 = `x`
	mov r30, #3
	mov r0, r30				// expr `mov x, 3`
	// prepare state for L16:
	stw r0, r31, #0

// stack is [`x`]
// from _L17:
L16:
	// decl `i`: u32
	// assign r0 = `i`
	mov r30, #0
	mov r0, r30				// expr `mov i, 0`

// expecting `r0` = `i`
// stack is [`x`, `i`]
// from L16:
L19:
	ult.e r0, #1000				// expr `ult i, 1000`
	c.jmp L20:				// expr `c.jmp L20:`

// expecting `r0` = `i`
// stack is [`x`, `i`]
// from L19:
_L23:
	// undecl `i`
	jmp L22:				// expr `jmp L22:`

// expecting `r0` = `i`
// stack is [`x`, `i`]
// from L19:
L20:
	ldw r1, r31, #0				// assign r1 = `x`
	ugt r0, r1				// expr `ugt i, x`
	c.jmp L25:				// expr `c.jmp L25:`

// expecting `r0` = `i`
// expecting `r1` = `x`
// stack is [`x`, `i`]
// from L20:
_L27:
	jmp L26:				// expr `jmp L26:`

// expecting `r0` = `i`
// expecting `r1` = `x`
// stack is [`x`, `i`]
// from L20:
L25:
	mov r1, r0				// expr `mov x, i`
	// undecl `i`
	// prepare state for L21:
	stw r1, r31, #0
	jmp L21:				// expr `jmp L21:`

// expecting `r0` = `i`
// expecting `r1` = `x`
// stack is [`x`, `i`]
// from _L27:
L26:
	// decl `t30`: u32
	// assign r2 = `t30`
	add r2, r0, #1				// expr `add t30, i, 1`
	mov r0, r2				// expr `mov i, t30`
	// undecl `t30`
	// prepare state for L19:
	stw r1, r31, #0
	jmp L19:				// expr `jmp L19:`

// stack is [`x`]
// from _L23:
L22:

// stack is [`x`]
// from L22:
L21:
	ldw r0, r31, #0				// assign r0 = `x`	// expr `retst 0, x`
	// undecl `x`
	ret 				// expr `ret`

//
// HSB
// args: x
//

// stack is []
// from _Main__:
_HSB__:
	// expr `argld x, 0`
	// decl `bit`: u32
	// decl `u_tbit`: u32
	// assign r1 = `u_tbit`
	mov r30, #1
	mov r1, r30				// expr `mov u_tbit, 1`

// expecting `r0` = `x`
// expecting `r1` = `u_tbit`
// stack is [`x`, `bit`, `u_tbit`]
// from _HSB__:
L1:
	ne r1, #0				// expr `ne u_tbit, 0`
	c.jmp L2:				// expr `c.jmp L2:`

// expecting `r0` = `x`
// expecting `r1` = `u_tbit`
// stack is [`x`, `bit`, `u_tbit`]
// from L1:
_L4:
	// undecl `x`
	// undecl `u_tbit`
	jmp L3:				// expr `jmp L3:`

// expecting `r0` = `x`
// expecting `r1` = `u_tbit`
// stack is [`x`, `bit`, `u_tbit`]
// from L1:
L2:
	// decl `t8`: u32
	// assign r2 = `t8`
	and r2, r0, r1				// expr `and t8, x, u_tbit`
	ne r2, #0				// expr `ne t8, 0`
	// undecl `t8`
	c.jmp L6:				// expr `c.jmp L6:`

// expecting `r0` = `x`
// expecting `r1` = `u_tbit`
// stack is [`x`, `bit`, `u_tbit`]
// from L2:
_L9:
	jmp L7:				// expr `jmp L7:`

// expecting `r0` = `x`
// expecting `r1` = `u_tbit`
// stack is [`x`, `bit`, `u_tbit`]
// from L2:
L6:
	ldw.e r2, r31, #32				// assign r2 = `bit`
	mov r2, r1				// expr `mov bit, u_tbit`
	// prepare state for L7:
	stw.e r2, r31, #32

// expecting `r0` = `x`
// expecting `r1` = `u_tbit`
// stack is [`x`, `bit`, `u_tbit`]
// from _L9:
L7:
	// decl `t11`: u32
	// assign r2 = `t11`
	bsl r2, r1, #1				// expr `bsl t11, u_tbit, 1`
	mov r1, r2				// expr `mov u_tbit, t11`
	// undecl `t11`
	// prepare state for L1:
	jmp L1:				// expr `jmp L1:`

// stack is [empty, `bit`]
// from _L4:
L3:
	ldw.e r0, r31, #32				// assign r0 = `bit`	// expr `retst 0, bit`
	// undecl `bit`
	ret 				// expr `ret`

    