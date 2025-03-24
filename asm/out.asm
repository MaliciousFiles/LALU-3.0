.DATA


.CODE
	mov.e r31, #928			// Setup stack pointer

//
// Main
// args: 
//

// stack is []
// from :
_Main__:
	breakpoint 				// expr `breakpoint`
	// decl `vec_0`: u32
	// decl `vec_1`: u32
	// memsave `vec_0`
	// memsave `vec_1`
	// assign r0 = `vec_0`
	mov r30, #7
	bst r0, r30, #0, #16				// expr `bst vec_0, 7, 0, 16`
	stw r0, r31, #0				// memsave r0 => `vec_0`
	// memsave `vec_1`
	// assign r1 = `vec_1`
	mov r30, #8
	bst r1, r30, #0, #0				// expr `bst vec_1, 8, 0, 0`
	// decl `t2`: u16
	// assign r2 = `t2`
	bsf r2, r0, #0, #16				// expr `bsf t2, vec_0, 0, 16`
	stw r0, r31, #0				// memsave r0 => `vec_0`
	stw.e r1, r31, #32				// memsave r1 => `vec_1`
	bst r0, r2, #16, #16				// expr `bst vec_0, t2, 16, 16`
	// undecl `t2`
	// decl `t3`: u8
	// assign r2 = `t3`
	mov r2, r0				// expr `mov t3, vec_0`
	// undecl `t3`
	// decl `node_0`: u32
	// decl `node_1`: u32
	// decl `node_2`: u32
	// decl `ptr`: u32
	// assign r2 = `ptr`
	add.e r29, r31, #64
	mov r2, r29				// expr `mov ptr, node_0.&`
	// memsave `node_0`
	// memsave `node_1`
	// memsave `node_2`
	// assign r3 = `node_2`
	bst r3, r2, #0, #0				// expr `bst node_2, ptr, 0, 0`
	// undecl `ptr`
	// memsave `node_0`
	// memsave `node_1`
	stw.e r3, r31, #128				// memsave r3 => `node_2`
	// assign r2 = `node_0`
	bst r2, r0, #0, #0				// expr `bst node_0, vec_0, 0, 0`
	// assign r4 = `node_1`
	bst r4, r1, #0, #0				// expr `bst node_1, vec_1, 0, 0`
	// undecl `vec_0`
	// undecl `vec_1`
	breakpoint 				// expr `breakpoint`
	// undecl `node_0`
	// undecl `node_1`
	// undecl `node_2`
	nop 				// expr `nop`
	nop 				// expr `nop`
	nop 				// expr `nop`
	nop 				// expr `nop`
	nop 				// expr `nop`
	susp 				// expr `susp`

    