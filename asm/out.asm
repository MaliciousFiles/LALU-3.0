	mov.e r31, #832			// Setup stack pointer

//
// Main
// args: 
//

// stack is []
// from :
_Main__:
	breakpoint 				// expr `breakpoint`
	// decl `vec_0`: u64
	// decl `vec_1`: u64
	// decl `t3_0`: u64
	// decl `t3_1`: u64
	// assign r0 = `t3_0`
	mov r0, #7				// expr `mov t3_0, 7`
	// assign r1 = `t3_1`
	mov r1, #0				// expr `mov t3_1, 0`
	// memsave `vec_0`
	add r29, r31, #0
	st r0, r29, #0, #16				// expr `st t3_0, vec_0.&, 0, 16`
	// regrst `vec_0`
	// undecl `t3_0`
	// undecl `t3_1`
	// decl `t5_0`: u64
	// decl `t5_1`: u64
	// assign r0 = `t5_0`
	mov r0, #8				// expr `mov t5_0, 8`
	// assign r1 = `t5_1`
	mov r1, #0				// expr `mov t5_1, 0`
	// memsave `vec_0`
	add r29, r31, #0
	st.e r0, r29, #32, #0				// expr `st t5_0, vec_0.&, 32, 0`
	// regrst `vec_0`
	// undecl `t5_0`
	// undecl `t5_1`
	// decl `t6`: u16
	// decl `t7_0`: u64
	// decl `t7_1`: u64
	// memsave `vec_0`
	// assign r0 = `t7_0`
	add r29, r31, #0
	ld r0, r29, #0, #16				// expr `ld t7_0, vec_0.&, 0, 16`
	// assign r1 = `t6`
	mov r1, r0				// expr `mov t6, t7_0`
	// undecl `t7_0`
	// undecl `t7_1`
	// decl `t8`: u16
	// assign r0 = `t8`
	mov r0, r1				// expr `mov t8, t6`
	// undecl `t6`
	// decl `t9_0`: u64
	// decl `t9_1`: u64
	// assign r1 = `t9_0`
	mov r1, r0				// expr `mov t9_0, t8`
	// assign r2 = `t9_1`
	mov r2, #0				// expr `mov t9_1, 0`
	// undecl `t8`
	// memsave `vec_0`
	add r29, r31, #0
	st r1, r29, #16, #16				// expr `st t9_0, vec_0.&, 16, 16`
	// regrst `vec_0`
	// undecl `t9_0`
	// undecl `t9_1`
	// undecl `vec_0`
	// undecl `vec_1`
	nop 				// expr `nop`
	nop 				// expr `nop`
	nop 				// expr `nop`
	nop 				// expr `nop`
	nop 				// expr `nop`
	susp 				// expr `susp`
