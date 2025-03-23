.DATA


.CODE
	mov.e r31, #672			// Setup stack pointer

//
// Main
// args: 
//

// stack is []
// from :
_Main__:
	breakpoint 				// expr `breakpoint`
	// decl `vec_0`: u32
	// decl `vec_1`: u64
	// assign r0 = `vec_0`
	bst r0, #7, #0, #16				// expr `bst vec_0, 7, 0, 16`
	// assign r1 = `vec_1`
	bst r1, #8, #0, #0				// expr `bst vec_1, 8, 0, 0`
	// decl `t2`: u16
	// assign r2 = `t2`
	bsf r2, r0, #0, #16				// expr `bsf t2, vec_0, 0, 16`
	bst r0, r2, #0, #16				// expr `bst vec_0, t2, 0, 16`
	// undecl `t2`
	// decl `t3`: u8
	// assign r2 = `t3`
	mov r2, r0				// expr `mov t3, vec_0`
	// undecl `t3`
	// decl `node_0`: u32
	// decl `node_1`: u32
	// decl `node_2`: u96
	// decl `ptr`: u32
	// assign r2 = `ptr`
	add.e r29, r31, #32
	mov r2, r29				// expr `mov ptr, node_0.&`
	// assign r3 = `node_2`
	bst r3, r2, #0, #0				// expr `bst node_2, ptr, 0, 0`
	// undecl `ptr`
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

    