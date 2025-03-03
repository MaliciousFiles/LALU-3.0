	mov.e r31, #512			// Setup stack pointer

//
// Main
// args: 
//

// stack is []
// from :
_Main__:
	// decl `x`: u32
	// assign r0 = `x`
	mov.e r0, #19088743				// expr `mov x, 19088743`
	// decl `t2`: u8
	// assign r1 = `t2`
	mov r1, r0				// expr `mov t2, x`
	// decl `y`: u8
	// assign r2 = `y`
	mov r2, r1				// expr `mov y, t2`
	// undecl `t2`
	breakpoint 				// expr `breakpoint `
	// decl `t4`: u8
	// decl `t5`: u32
	// assign r1 = `t5`
	bsf r1, r0, #0, #8				// expr `bsf t5, x, 0, 8`
	// assign r3 = `t4`
	mov r3, r1				// expr `mov t4, t5`
	// undecl `t5`
	// decl `lowest`: u8
	// assign r1 = `lowest`
	mov r1, r3				// expr `mov lowest, t4`
	// undecl `t4`
	// undecl `y`
	bst r0, r1, #8, #8				// expr `bst x, lowest, 8, 8`
	// undecl `lowest`
	// undecl `x`
	nop 				// expr `nop `
	nop 				// expr `nop `
	nop 				// expr `nop `
	nop 				// expr `nop `
	susp 				// expr `susp `
