	mov.e r31, #512			// Setup stack pointer

//
// Main
// args: 
//

// stack is []
// from :
_Main__:
	// decl `x_0`: u64
	// decl `x_1`: u64
	// assign r0 = `x_0`
	mov.e r0, #19088743				// expr `mov x_0, 19088743`
	// assign r1 = `x_1`
	mov r1, #0				// expr `mov x_1, 0`
	breakpoint 				// expr `breakpoint `
	// decl `t3`: u32
	// decl `t4_0`: u64
	// decl `t4_1`: u64
	// memsave `t4_0.&`
	// assign r2 = `t4_0`
	add r29, r31, #0
	ld.e r2, r29, #0, #32				// expr `ld t4_0, x_0.&, 0, 32`
	// undecl `x_0`
	// undecl `x_1`
	// assign r0 = `t3`
	mov r0, r2				// expr `mov t3, t4_0`
	// undecl `t4_0`
	// undecl `t4_1`
	// decl `lowest`: u32
	// assign r1 = `lowest`
	mov r1, r0				// expr `mov lowest, t3`
	// undecl `t3`
	// undecl `lowest`
	nop 				// expr `nop `
	nop 				// expr `nop `
	nop 				// expr `nop `
	nop 				// expr `nop `
	susp 				// expr `susp `
