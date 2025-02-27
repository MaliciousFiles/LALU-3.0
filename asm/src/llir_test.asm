	mov.e r31, #1024
_Main__:
	// decl `n`: u32
	ldw r0, r31, #0
	// assign r0 = `n`
	mov r0, #5
	mov r0, r0				// expr `mov n, 5`
	// undecl `n`
	add.e r31, r31, #32				// expr `argst 0, n`
	call _Fac__:
	// decl `t2`: u32
	// undecl `t2`
	susp 				// expr `call Fac`	// expr `retld t2, 0`
_Fac__:
	eq r0, #1				// expr `susp `	// expr `argld n, 0`
	c.jmp L4:				// expr `eq n, 1`
_L6:
	jmp L5:				// expr `c.jmp L4:`
L4:
	// undecl `n`
	mov r0, #1				// expr `jmp L5:`
	sub.e r31, r31, #32				// expr `retst 0, 1`
	ret
L5:
	// decl `t9`: u32
	ldw.e r1, r31, #32				// expr `ret `
	// assign r1 = `t9`
	sub r1, r0, #1
	mov r0, r1				// expr `sub t9, n, 1`
	// undecl `t9`
	stw r0, r31, #0				// expr `argst 0, t9`
	add.e r31, r31, #64
	call _Fac__:
	// decl `t10`: u32
	// decl `t11`: u32
	ldw.e r1, r31, #128				// expr `call Fac`	// expr `retld t10, 0`
	// assign r1 = `t11`
	ldw r2, r31, #0
	// assign r2 = `n`
	mul r1, r2, r0
	// undecl `t10`
	// undecl `n`
	mov r0, r1				// expr `mul t11, n, t10`
	// undecl `t11`
	sub.e r31, r31, #160				// expr `retst 0, t11`
	ret