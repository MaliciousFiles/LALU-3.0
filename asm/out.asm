.DATA


.CODE
	mov.e r31, #2144			// Setup stack pointer

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
	// alloc `ary`: u16[2]
	eq r1, #4				// expr `eq magic, 4`
	// undecl `magic`
	c.jmp L15:				// expr `c.jmp L15:`

// stack is [`x`, `_ARRAY_ary`, `ary`]
// from _Main__:
_L17:
	jmp L16:				// expr `jmp L16:`

// stack is [`x`, `_ARRAY_ary`, `ary`]
// from _Main__:
L15:
	ldw r0, r31, #0				// assign r0 = `x`
	mov r30, #3
	mov r0, r30				// expr `mov x, 3`
	// prepare state for L16:
	stw r0, r31, #0

// stack is [`x`, `_ARRAY_ary`, `ary`]
// from _L17:
L16:
	// decl `t19`: u32
	// assign r0 = `t19`
	mov r30, #0
	mul.e r0, r30, #32				// expr `mul t19, 0, 32`
	ldw.e r1, r31, #64				// assign r1 = `ary`
	mov r29, #0
	stw r29, r1, r0				// expr `stw 0, ary, t19`
	// undecl `t19`
	// decl `i`: u32
	// assign r0 = `i`
	mov r30, #0
	mov r0, r30				// expr `mov i, 0`

// expecting `r0` = `i`
// expecting `r1` = `ary`
// stack is [`x`, `_ARRAY_ary`, `ary`, `i`]
// from L16:
L20:
	ult.e r0, #1000				// expr `ult i, 1000`
	c.jmp L21:				// expr `c.jmp L21:`

// expecting `r0` = `i`
// expecting `r1` = `ary`
// stack is [`x`, `_ARRAY_ary`, `ary`, `i`]
// from L20:
_L24:
	// undecl `i`
	jmp L23:				// expr `jmp L23:`

// expecting `r0` = `i`
// expecting `r1` = `ary`
// stack is [`x`, `_ARRAY_ary`, `ary`, `i`]
// from L20:
L21:
	ldw r2, r31, #0				// assign r2 = `x`
	ugt r0, r2				// expr `ugt i, x`
	c.jmp L26:				// expr `c.jmp L26:`

// expecting `r0` = `i`
// expecting `r1` = `ary`
// expecting `r2` = `x`
// stack is [`x`, `_ARRAY_ary`, `ary`, `i`]
// from L21:
_L28:
	jmp L27:				// expr `jmp L27:`

// expecting `r0` = `i`
// expecting `r1` = `ary`
// expecting `r2` = `x`
// stack is [`x`, `_ARRAY_ary`, `ary`, `i`]
// from L21:
L26:
	mov r2, r0				// expr `mov x, i`
	// undecl `i`
	// prepare state for L22:
	stw r2, r31, #0
	jmp L22:				// expr `jmp L22:`

// expecting `r0` = `i`
// expecting `r1` = `ary`
// expecting `r2` = `x`
// stack is [`x`, `_ARRAY_ary`, `ary`, `i`]
// from _L28:
L27:
	// decl `t31`: u32
	// assign r3 = `t31`
	add r3, r0, #1				// expr `add t31, i, 1`
	mov r0, r3				// expr `mov i, t31`
	// undecl `t31`
	// prepare state for L20:
	stw r2, r31, #0
	jmp L20:				// expr `jmp L20:`

// expecting `r1` = `ary`
// stack is [`x`, `_ARRAY_ary`, `ary`]
// from _L24:
L23:

// expecting `r1` = `ary`
// stack is [`x`, `_ARRAY_ary`, `ary`]
// from L23:
L22:
	// decl `t33`: u32
	// assign r0 = `t33`
	mov r30, #1
	mul.e r0, r30, #32				// expr `mul t33, 1, 32`
	// decl `t34`: u16
	// memsave `t34`
	// assign r2 = `t34`
	ldw r2, r1, r0				// expr `ldw t34, ary, t33`
	// undecl `ary`
	// undecl `t33`
	// decl `t35`: u32
	// assign r0 = `t35`
	ldw r1, r31, #0				// assign r1 = `x`
	add r0, r1, r2				// expr `add t35, x, t34`
	// undecl `x`
	// undecl `t34`
	// expr `retst 0, t35`
	// undecl `t35`
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

    