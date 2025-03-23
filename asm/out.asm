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
	mov r0, #5				// expr `argst 0, 5`
	add r31, r31, #0
	call _Fib__:
	sub r31, r31, #0				// expr `call Fib`
	// decl `t1`: u32
	// expr `retld t1, 0`
	// undecl `t1`
	// decl `u_t__0`: u32
	// assign r0 = `u_t__0`
	mov r0, #5				// expr `mov u_t__0, 5`
	stw r0, r31, #0
	mov r0, #7				// expr `argst 0, 7`
	mov r1, #7				// expr `argst 1, 7`
	add.e r31, r31, #96
	call _AssertEql__:
	sub.e r31, r31, #96				// expr `call AssertEql`
	// expr `retld t2, 0`
	stw.e r0, r31, #32				// clobbering r0 (`t2`)
	ldw r0, r31, #0				// assign r0 = `u_t__0`	// expr `retst 0, u_t__0`
	// undecl `u_t__0`
	ret 				// expr `ret`

//
// Fib
// args: x
//

// stack is []
// from _Main__:
_Fib__:
	// expr `argld x, 0`
	eq r0, #1				// expr `eq x, 1`
	c.jmp L4:				// expr `c.jmp L4:`

// expecting `r0` = `x`
// stack is [`x`]
// from _Fib__:
_L7:
	jmp L6:				// expr `jmp L6:`

// expecting `r0` = `x`
// stack is [`x`]
// from _L7:
L6:
	eq r0, #0				// expr `eq x, 0`
	// prepare state for L4:
	c.jmp L4:				// expr `c.jmp L4:`

// expecting `r0` = `x`
// stack is [`x`]
// from L6:
_L9:
	jmp L5:				// expr `jmp L5:`

// expecting `r0` = `x`
// stack is [`x`]
// from _Fib__:
L4:
	// undecl `x`
	mov r0, #1				// expr `retst 0, 1`
	ret 				// expr `ret`

// expecting `r0` = `x`
// stack is [`x`]
// from _L9:
L5:
	// decl `t13`: u32
	// assign r1 = `t13`
	sub r1, r0, #2				// expr `sub t13, x, 2`
	stw r0, r31, #0				// clobbering r0 (`x`)
	mov r0, r1				// assign r0 = `t13`	// expr `argst 0, t13`
	// undecl `t13`
	add.e r31, r31, #64
	call _Fib__:
	sub.e r31, r31, #64				// expr `call Fib`
	// decl `t14`: u32
	// expr `retld t14, 0`
	// decl `t15`: u32
	// assign r1 = `t15`
	ldw r2, r31, #0				// assign r2 = `x`
	sub r1, r2, #1				// expr `sub t15, x, 1`
	// undecl `x`
	stw.e r0, r31, #64				// clobbering r0 (`t14`)
	mov r0, r1				// assign r0 = `t15`	// expr `argst 0, t15`
	// undecl `t15`
	add.e r31, r31, #160
	call _Fib__:
	sub.e r31, r31, #160				// expr `call Fib`
	// decl `t16`: u32
	// expr `retld t16, 0`
	// decl `t17`: u32
	// assign r1 = `t17`
	ldw.e r2, r31, #64				// assign r2 = `t14`
	add r1, r2, r0				// expr `add t17, t14, t16`
	// undecl `t16`
	// undecl `t14`
	mov r0, r1				// assign r0 = `t17`	// expr `retst 0, t17`
	// undecl `t17`
	ret 				// expr `ret`

//
// AssertEql
// args: act, exp
//

// stack is []
// from _Main__:
_AssertEql__:
	// expr `argld act, 0`
	// expr `argld exp, 1`
	ne r0, r1				// expr `ne act, exp`
	// undecl `exp`
	// undecl `act`
	c.jmp L19:				// expr `c.jmp L19:`

// stack is []
// from _AssertEql__:
_L21:
	jmp L20:				// expr `jmp L20:`

// stack is []
// from _AssertEql__:
L19:
	susp 				// expr `susp`
	// prepare state for L20:

// stack is []
// from _L21:
L20:
	ret 				// expr `ret`

    