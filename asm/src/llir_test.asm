	mov.e r31, #960
_Main__:
	// decl `n`: u32
	// assign r0 = `n`
	ldw r0, r31, #0
	mov r0, #5				// expr `mov n, 5`
	mov r0, r0				// expr `argst 0, n`
	// undecl `n`
	add.e r31, r31, #32
	call _Fac__:				// expr `call Fac`
	// decl `t2`: u32
	// expr `retld t2, 0`
	// undecl `t2`
	susp 				// expr `susp `
_Fac__:
	// expr `argld n, 0`
	eq r0, #1				// expr `eq n, 1`
	c.jmp L4:				// expr `c.jmp L4:`
_L6:
	jmp L5:				// expr `jmp L5:`
L4:
	// undecl `n`
	mov r0, #1				// expr `retst 0, 1`
	sub r31, r31, #0
	ret 				// expr `ret `
L5:
	// decl `t9`: u32
	// assign r1 = `t9`
	ldw.e r1, r31, #32
	sub r1, r0, #1				// expr `sub t9, n, 1`
	mov r0, r1				// expr `argst 0, t9`
	// undecl `t9`
	add.e r31, r31, #64
	call _Fac__:				// expr `call Fac`
	// decl `t10`: u32
	// expr `retld t10, 0`
	// decl `t11`: u32
	// assign r1 = `t11`
	ldw.e r1, r31, #128
	// assign r2 = `n`
	ldw r2, r31, #0
	mul r1, r2, r0				// expr `mul t11, n, t10`
	// undecl `t10`
	// undecl `n`
	mov r0, r1				// expr `retst 0, t11`
	// undecl `t11`
	sub.e r31, r31, #128
	ret 				// expr `ret `