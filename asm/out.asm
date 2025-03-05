	mov.e r31, #608			// Setup stack pointer

//
// Main
// args: 
//

// stack is []
// from :
_Main__:
	breakpoint 				// expr `breakpoint `
	// decl `vec`: u32
	// decl `t3`: u15
	// assign r0 = `t3`
	mov r0, #7				// expr `mov t3, 7`
	// memsave `vec`
	add r29, r31, #0
	st r0, r29, #0, #15				// expr `st t3, vec.&, 0, 15`
	// regrst `vec`
	// undecl `t3`
	// decl `t5`: u32
	// assign r0 = `t5`
	mov r0, #8				// expr `mov t5, 8`
	// assign r1 = `vec`
	bst.e r1, r0, #32, #0				// expr `bst vec, t5, 32, 0`
	// undecl `t5`
	// decl `t7`: u16
	// assign r0 = `t7`
	mov r0, #9				// expr `mov t7, 9`
	stw r1, r31, #0				// memsave r1 => `vec`
	add r29, r31, #0
	st r0, r29, #15, #16				// expr `st t7, vec.&, 15, 16`	// regrst r1 (`vec`) => None
	// undecl `t7`
	// undecl `vec`
	nop 				// expr `nop `
	nop 				// expr `nop `
	nop 				// expr `nop `
	nop 				// expr `nop `
	nop 				// expr `nop `
	susp 				// expr `susp `
