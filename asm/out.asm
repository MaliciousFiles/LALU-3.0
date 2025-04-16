.DATA


.CODE
	mov.e r31, #2048			// Setup stack pointer

//
// Main
// args: 
//

// stack is []
// from :
_Main__:
	// decl `t3_0`: u32
	// decl `t3_1`: u32
	// memsave `t3_0`
	// memsave `t3_1`
	// assign r0 = `t3_0`
	mov r30, #3
	bst r0, r30, #0, #0				// expr `bst t3_0, 3, 0, 0`
	stw r0, r31, #0				// memsave r0 => `t3_0`
	// memsave `t3_1`
	// assign r1 = `t3_1`
	mov r30, #5
	bst r1, r30, #0, #0				// expr `bst t3_1, 5, 0, 0`
	// decl `v_0`: u32
	// decl `v_1`: u32
	// assign r2 = `v_0`
	mov r2, r0				// expr `mov v_0, t3_0`
	// assign r3 = `v_1`
	mov r3, r1				// expr `mov v_1, t3_1`
	// undecl `t3_0`
	// undecl `t3_1`
	// decl `vptr`: u32
	// assign r0 = `vptr`
	add.e r29, r31, #64
	mov r0, r29				// expr `mov vptr, v_0.&`
	// memsave `t3_0`
	// memsave `t3_1`
	stw.e r2, r31, #64				// memsave r2 => `v_0`
	stw.e r3, r31, #96				// memsave r3 => `v_1`
	mov r29, #7
	st.e r29, r0, #0, #32				// expr `st 7, vptr, 0, 32`	// regrst r2 (`v_0`) => None	// regrst r3 (`v_1`) => None
	// regrst `t3_0`
	// regrst `t3_1`
	// decl `t5_0`: u32
	// decl `t5_1`: u32
	// memsave `t3_0`
	// memsave `t3_1`
	// memsave `v_0`
	// memsave `v_1`
	// memsave `t5_0`
	// memsave `t5_1`
	// assign r1 = `t5_0`
	ld r1, r0, #0, #0				// expr `ld t5_0, vptr, 0, 0`
	// assign r2 = `t5_1`
	ld.e r2, r0, #32, #0				// expr `ld t5_1, vptr, 32, 0`
	// undecl `vptr`
	// decl `w_0`: u32
	// decl `w_1`: u32
	// assign r0 = `w_0`
	mov r0, r1				// expr `mov w_0, t5_0`
	// assign r3 = `w_1`
	mov r3, r2				// expr `mov w_1, t5_1`
	// undecl `t5_0`
	// undecl `t5_1`
	// decl `wptr`: u32
	// assign r1 = `wptr`
	add r29, r31, #0
	mov r1, r29				// expr `mov wptr, w_0.&`
	// decl `t6_0`: u32
	// decl `t6_1`: u32
	// memsave `t3_0`
	// memsave `t3_1`
	// memsave `v_0`
	// memsave `v_1`
	// memsave `t5_0`
	// memsave `t5_1`
	stw r0, r31, #0				// memsave r0 => `w_0`
	stw.e r3, r31, #160				// memsave r3 => `w_1`
	// memsave `t6_0`
	// memsave `t6_1`
	// assign r2 = `t6_0`
	mov r30, #1
	bst r2, r30, #0, #0				// expr `bst t6_0, 1, 0, 0`
	// memsave `t3_0`
	// memsave `t3_1`
	// memsave `v_0`
	// memsave `v_1`
	// memsave `t5_0`
	// memsave `t5_1`
	stw r0, r31, #0				// memsave r0 => `w_0`
	stw.e r3, r31, #160				// memsave r3 => `w_1`
	stw.e r2, r31, #128				// memsave r2 => `t6_0`
	// memsave `t6_1`
	// assign r4 = `t6_1`
	mov r30, #1
	bst r4, r30, #0, #0				// expr `bst t6_1, 1, 0, 0`
	// memsave `t3_0`
	// memsave `t3_1`
	// memsave `v_0`
	// memsave `v_1`
	// memsave `t5_0`
	// memsave `t5_1`
	stw r0, r31, #0				// memsave r0 => `w_0`
	stw.e r3, r31, #160				// memsave r3 => `w_1`
	stw.e r2, r31, #128				// memsave r2 => `t6_0`
	stw.e r4, r31, #192				// memsave r4 => `t6_1`
	st r2, r1, #0, #0				// expr `st t6_0, wptr, 0, 0`
	st.e r4, r1, #32, #0				// expr `st t6_1, wptr, 32, 0`	// regrst r0 (`w_0`) => None	// regrst r3 (`w_1`) => None
	// undecl `t6_0`
	// undecl `t6_1`
	// undecl `wptr`
	// regrst `t3_0`
	// regrst `t3_1`
	// regrst `v_0`
	// regrst `v_1`
	// regrst `t5_0`
	// regrst `t5_1`
	// regrst `t6_0`
	// regrst `t6_1`
	add.e r0, r31, #64				// expr `argst 0, v_0.&`
	add.e r31, r31, #384
	call _u_Vec____Nop__:
	sub.e r31, r31, #384				// expr `call u_Vec____Nop`
	// decl `t8`: u32
	// assign r0 = `t8`
	ldw.e r1, r31, #64				// assign r1 = `v_0`
	bsf r0, r1, #0, #0				// expr `bsf t8, v_0, 0, 0`
	// undecl `v_0`
	// undecl `v_1`
	// decl `t9`: u32
	// assign r1 = `t9`
	ldw r2, r31, #0				// assign r2 = `w_0`
	bsf r1, r2, #0, #0				// expr `bsf t9, w_0, 0, 0`
	// undecl `w_0`
	// undecl `w_1`
	// decl `t10`: u32
	// assign r2 = `t10`
	sub r2, r0, r1				// expr `sub t10, t8, t9`
	// undecl `t9`
	// undecl `t8`
	mov r0, r2				// assign r0 = `t10`	// expr `retst 0, t10`
	// undecl `t10`
	ret 				// expr `ret`

//
// u_Vec____Nop
// args: self
//

// stack is []
// from _Main__:
_u_Vec____Nop__:
	// expr `argld self, 0`
	// undecl `self`
	ret 				// expr `ret`

    