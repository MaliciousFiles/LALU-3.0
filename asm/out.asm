.DATA


.CODE
	mov.e r31, #1120			// Setup stack pointer

//
// Main
// args: 
//

// stack is []
// from :
_Main__:
	add r31, r31, #0
	call _u_Vec____Zero__:
	sub r31, r31, #0				// expr `call u_Vec____Zero`
	// decl `t7_0`: u32
	// decl `t7_1`: u32
	// expr `retld t7_0, 0`
	// expr `retld t7_1, 1`
	// decl `v_0`: u32
	// decl `v_1`: u32
	// assign r2 = `v_0`
	mov r2, r0				// expr `mov v_0, t7_0`
	// assign r3 = `v_1`
	mov r3, r1				// expr `mov v_1, t7_1`
	// undecl `t7_0`
	// undecl `t7_1`
	add.e r0, r31, #32				// expr `argst 0, v_0.&`
	// undecl `v_0`
	// undecl `v_1`
	add.e r31, r31, #192
	call _u_Vec____AddXOne__:
	sub.e r31, r31, #192				// expr `call u_Vec____AddXOne`
	// expr `retld t8, 0`

//
// u_Vec____Zero
// args: 
//

// stack is []
// from _Main__:
_u_Vec____Zero__:
	// decl `t1_0`: u32
	// decl `t1_1`: u32
	// memsave `t1_0`
	// memsave `t1_1`
	// assign r0 = `t1_0`
	mov r30, #0
	bst r0, r30, #0, #0				// expr `bst t1_0, 0, 0, 0`
	stw r0, r31, #0				// memsave r0 => `t1_0`
	// memsave `t1_1`
	// assign r1 = `t1_1`
	mov r30, #0
	bst r1, r30, #0, #0				// expr `bst t1_1, 0, 0, 0`
	// expr `retst 0, t1_0`
	// expr `retst 1, t1_1`
	// undecl `t1_0`
	// undecl `t1_1`
	ret 				// expr `ret`

//
// u_Vec____AddXOne
// args: self
//

// stack is []
// from _Main__:
_u_Vec____AddXOne__:
	// expr `argld self, 0`
	// decl `t3_0`: u32
	// decl `t3_1`: u32
	// memsave `t3_0`
	// memsave `t3_1`
	// assign r1 = `t3_0`
	ld r1, r0, #0, #0				// expr `ld t3_0, self, 0, 0`
	// assign r2 = `t3_1`
	ld r2, r0, #1, #0				// expr `ld t3_1, self, 1, 0`
	// decl `t4_0`: u32
	// decl `t4_1`: u32
	stw.e r1, r31, #32				// memsave r1 => `t3_0`
	stw.e r2, r31, #64				// memsave r2 => `t3_1`
	// memsave `t4_0`
	// memsave `t4_1`
	// assign r3 = `t4_0`
	ld r3, r0, #0, #0				// expr `ld t4_0, self, 0, 0`
	// assign r4 = `t4_1`
	ld r4, r0, #1, #0				// expr `ld t4_1, self, 1, 0`
	// undecl `self`
	// decl `t5`: u32
	// assign r0 = `t5`
	bsf r0, r3, #0, #0				// expr `bsf t5, t4_0, 0, 0`
	// undecl `t4_0`
	// undecl `t4_1`
	// decl `t6`: u32
	// assign r3 = `t6`
	add r3, r0, #1				// expr `add t6, t5, 1`
	// undecl `t5`
	stw.e r1, r31, #32				// memsave r1 => `t3_0`
	stw.e r2, r31, #64				// memsave r2 => `t3_1`
	// memsave `t4_0`
	// memsave `t4_1`
	bst r1, r3, #0, #0				// expr `bst t3_0, t6, 0, 0`
	// undecl `t6`
	// undecl `t3_0`
	// undecl `t3_1`

    