.DATA


.CODE
	mov.e r31, #1152			// Setup stack pointer

//
// Main
// args: 
//

// stack is []
// from :
_Main__:
	breakpoint 				// expr `breakpoint`
	// decl `x`: u32
	// assign r0 = `x`
	mov r0, #3				// expr `mov x, 3`
	// decl `xptr`: u32
	// assign r1 = `xptr`
	add r29, r31, #0
	mov r1, r29				// expr `mov xptr, x.&`
	breakpoint 				// expr `breakpoint`
	// decl `t3`: u32
	// decl `t4`: u32
	// memsave `t1`
	stw r0, r31, #0				// memsave r0 => `x`
	// memsave `t2`
	// memsave `t3`
	// memsave `t4`
	// assign r2 = `t4`
	ldw r2, r1, #0				// expr `ldw t4, xptr, 0`
	// assign r3 = `t3`
	add r3, r2, #1				// expr `add t3, t4, 1`
	// undecl `t4`
	// memsave `t1`
	stw r0, r31, #0				// memsave r0 => `x`
	// memsave `t2`
	stw.e r3, r31, #64				// memsave r3 => `t3`
	// memsave `t4`
	stw r1, #0, r3				// expr `stw xptr, 0, t3`	// regrst r0 (`x`) => None
	// undecl `t3`
	// regrst `t1`
	// regrst `t2`
	// regrst `t3`
	// regrst `t4`
	breakpoint 				// expr `breakpoint`
	// decl `vec_0`: u32
	// decl `vec_1`: u32
	// decl `vecptr`: u32
	// assign r0 = `vecptr`
	add.e r29, r31, #64
	mov r0, r29				// expr `mov vecptr, vec_0.&`
	// undecl `vec_0`
	// undecl `vec_1`
	breakpoint 				// expr `breakpoint`
	// memsave `vec_0`
	// memsave `vec_1`
	mov r29, #0
	st r29, r0, #0, #0				// expr `st 0, vecptr, 0, 0`
	mov r29, #0
	st r29, r0, #1, #0				// expr `st 0, vecptr, 1, 0`
	// undecl `vecptr`
	// regrst `vec_0`
	// regrst `vec_1`
	// memsave `t1`
	// memsave `x`
	// memsave `t2`
	// memsave `t3`
	// memsave `t4`
	// memsave `t5`
	// memsave `t6`
	stw r1, #0, #7				// expr `stw xptr, 0, 7`
	// regrst `t1`
	// regrst `x`
	// regrst `t2`
	// regrst `t3`
	// regrst `t4`
	// regrst `t5`
	// regrst `t6`
	breakpoint 				// expr `breakpoint`
	// decl `ft`: u15
	// assign r0 = `ft`
	mov r0, #1				// expr `mov ft, 1`
	// decl `ftptr`: u32
	// assign r2 = `ftptr`
	add.e r29, r31, #64
	mov r2, r29				// expr `mov ftptr, ft.&`
	// undecl `ft`
	// memsave `ft`
	mov r29, #6
	st r29, r2, #0, #16				// expr `st 6, ftptr, 0, 16`
	// undecl `ftptr`
	// regrst `ft`
	// undecl `x`
	// undecl `xptr`
	nop 				// expr `nop`
	nop 				// expr `nop`
	nop 				// expr `nop`
	nop 				// expr `nop`
	susp 				// expr `susp`

    