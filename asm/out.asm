.DATA


.CODE
	mov.e r31, #21216			// Setup stack pointer

//
// Main
// args: 
//

// stack is []
// from :
_Main__:
	// alloc `memory`: u64[32768]
	// assign r0 = `memory`
	// expr `argst 0, memory`
	// undecl `memory`
	add.e r31, r31, #64
	call _u_Block____MemInit__:
	sub.e r31, r31, #64				// expr `call u_Block____MemInit`
	// decl `rs_0`: u32
	// decl `rs_1`: u32
	// decl `rs_2`: u32
	// decl `rs_3`: u32
	// decl `rs_4`: u32
	// decl `rs_5`: u32
	// decl `rs_6`: u32
	// decl `rs_7`: u32
	// decl `rs_8`: u32
	add r0, r31, #0				// expr `argst 0, rs_0.&`
	add.e r31, r31, #352
	call _u_RenderState____Init__:
	sub.e r31, r31, #352				// expr `call u_RenderState____Init`
	add r0, r31, #0				// expr `argst 0, rs_0.&`
	// undecl `rs_0`
	// undecl `rs_1`
	// undecl `rs_2`
	// undecl `rs_3`
	// undecl `rs_4`
	// undecl `rs_5`
	// undecl `rs_6`
	// undecl `rs_7`
	// undecl `rs_8`
	add.e r31, r31, #352
	call _u_RenderState____Draw__:
	sub.e r31, r31, #352				// expr `call u_RenderState____Draw`
	ret 				// expr `ret`

//
// u_Block____MemInit
// args: memory
//

// stack is []
// from _Main__:
_u_Block____MemInit__:
	// expr `argld memory, 0`
	// decl `nblock_0`: u32
	// decl `nblock_1`: u32
	// memsave `nblock_0`
	// memsave `nblock_1`
	// assign r1 = `nblock_0`
	mov r30, #0
	bst r1, r30, #0, #0				// expr `bst nblock_0, 0, 0, 0`
	stw.e r1, r31, #32				// memsave r1 => `nblock_0`
	// memsave `nblock_1`
	// assign r2 = `nblock_1`
	mov.e r30, #32768
	bst.e r2, r30, #0, #31				// expr `bst nblock_1, 32768, 0, 31`
	stw.e r1, r31, #32				// memsave r1 => `nblock_0`
	stw.e r2, r31, #64				// memsave r2 => `nblock_1`
	mov r30, #1
	bst.e r2, r30, #31, #1				// expr `bst nblock_1, 1, 31, 1`
	// decl `t1`: u32
	// assign r3 = `t1`
	mov r30, #0
	mul.e r3, r30, #32				// expr `mul t1, 0, 32`
	stw.e r1, r31, #32				// memsave r1 => `nblock_0`
	stw.e r2, r31, #64				// memsave r2 => `nblock_1`
	// decl `t_hl0`: u32
	// assign r4 = `t_hl0`
	mov r30, #0
	mov r4, r30				// expr `mov t_hl0, 0`
	st r1, r0, r4, #0				// expr `st nblock_0, memory, t_hl0, 0`
	add.e r4, r4, #32				// expr `add t_hl0, t_hl0, 32`
	st r2, r0, r4, #0				// expr `st nblock_1, memory, t_hl0, 0`
	add.e r4, r4, #32				// expr `add t_hl0, t_hl0, 32`
	// undecl `t_hl0`
	// undecl `t1`
	// undecl `nblock_0`
	// undecl `nblock_1`
	// undecl `memory`
	// regrst `nblock_0`
	// regrst `nblock_1`

//
// u_Block____Malloc
// args: memory, size
//

//
// u_RenderState____Init
// args: self
//

// stack is []
// from _Main__:
_u_RenderState____Init__:
	// expr `argld self, 0`
	// decl `t98_0`: u32
	// decl `t98_1`: u32
	// decl `t98_2`: u32
	// decl `t98_3`: u32
	// decl `t98_4`: u32
	// decl `t98_5`: u32
	// decl `t98_6`: u32
	// decl `t98_7`: u32
	// decl `t98_8`: u32
	// memsave `t98_0`
	// memsave `t98_1`
	// memsave `t98_2`
	// memsave `t98_3`
	// memsave `t98_4`
	// memsave `t98_5`
	// memsave `t98_6`
	// memsave `t98_7`
	// memsave `t98_8`
	// assign r1 = `t98_0`
	ld r1, r0, #0, #0				// expr `ld t98_0, self, 0, 0`
	// assign r2 = `t98_1`
	ld.e r2, r0, #32, #0				// expr `ld t98_1, self, 32, 0`
	// assign r3 = `t98_2`
	ld.e r3, r0, #64, #0				// expr `ld t98_2, self, 64, 0`
	// assign r4 = `t98_3`
	ld.e r4, r0, #96, #0				// expr `ld t98_3, self, 96, 0`
	// assign r5 = `t98_4`
	ld.e r5, r0, #128, #0				// expr `ld t98_4, self, 128, 0`
	// assign r6 = `t98_5`
	ld.e r6, r0, #160, #0				// expr `ld t98_5, self, 160, 0`
	// assign r7 = `t98_6`
	ld.e r7, r0, #192, #0				// expr `ld t98_6, self, 192, 0`
	// assign r8 = `t98_7`
	ld.e r8, r0, #224, #0				// expr `ld t98_7, self, 224, 0`
	// assign r9 = `t98_8`
	ld.e r9, r0, #256, #0				// expr `ld t98_8, self, 256, 0`
	// decl `t99_0`: u32
	// decl `t99_1`: u32
	stw.e r3, r31, #96				// memsave r3 => `t98_2`
	stw.e r4, r31, #128				// memsave r4 => `t98_3`
	stw.e r5, r31, #160				// memsave r5 => `t98_4`
	stw.e r6, r31, #192				// memsave r6 => `t98_5`
	// memsave `t99_0`
	// memsave `t99_1`
	// assign r10 = `t99_0`
	mov r30, #0
	bst r10, r30, #0, #0				// expr `bst t99_0, 0, 0, 0`
	stw.e r3, r31, #96				// memsave r3 => `t98_2`
	stw.e r4, r31, #128				// memsave r4 => `t98_3`
	stw.e r5, r31, #160				// memsave r5 => `t98_4`
	stw.e r6, r31, #192				// memsave r6 => `t98_5`
	stw.e r10, r31, #320				// memsave r10 => `t99_0`
	// memsave `t99_1`
	// assign r11 = `t99_1`
	mov r30, #0
	bst r11, r30, #0, #0				// expr `bst t99_1, 0, 0, 0`
	stw.e r1, r31, #32				// memsave r1 => `t98_0`
	stw.e r2, r31, #64				// memsave r2 => `t98_1`
	stw.e r3, r31, #96				// memsave r3 => `t98_2`
	stw.e r4, r31, #128				// memsave r4 => `t98_3`
	stw.e r5, r31, #160				// memsave r5 => `t98_4`
	stw.e r6, r31, #192				// memsave r6 => `t98_5`
	stw.e r7, r31, #224				// memsave r7 => `t98_6`
	stw.e r8, r31, #256				// memsave r8 => `t98_7`
	stw.e r9, r31, #288				// memsave r9 => `t98_8`
	bst r3, r10, #0, #0				// expr `bst t98_2, t99_0, 0, 0`
	bst r4, r11, #0, #0				// expr `bst t98_3, t99_1, 0, 0`
	// undecl `t99_0`
	// undecl `t99_1`
	// undecl `t98_0`
	// undecl `t98_1`
	// undecl `t98_2`
	// undecl `t98_3`
	// undecl `t98_4`
	// undecl `t98_5`
	// undecl `t98_6`
	// undecl `t98_7`
	// undecl `t98_8`
	// decl `t100_0`: u32
	// decl `t100_1`: u32
	// decl `t100_2`: u32
	// decl `t100_3`: u32
	// decl `t100_4`: u32
	// decl `t100_5`: u32
	// decl `t100_6`: u32
	// decl `t100_7`: u32
	// decl `t100_8`: u32
	// memsave `t98_0`
	// memsave `t98_1`
	// memsave `t98_2`
	// memsave `t98_3`
	// memsave `t98_4`
	// memsave `t98_5`
	// memsave `t98_6`
	// memsave `t98_7`
	// memsave `t98_8`
	// memsave `t100_0`
	// memsave `t100_1`
	// memsave `t100_2`
	// memsave `t100_3`
	// memsave `t100_4`
	// memsave `t100_5`
	// memsave `t100_6`
	// memsave `t100_7`
	// memsave `t100_8`
	// assign r1 = `t100_0`
	ld r1, r0, #0, #0				// expr `ld t100_0, self, 0, 0`
	// assign r2 = `t100_1`
	ld.e r2, r0, #32, #0				// expr `ld t100_1, self, 32, 0`
	// assign r3 = `t100_2`
	ld.e r3, r0, #64, #0				// expr `ld t100_2, self, 64, 0`
	// assign r4 = `t100_3`
	ld.e r4, r0, #96, #0				// expr `ld t100_3, self, 96, 0`
	// assign r5 = `t100_4`
	ld.e r5, r0, #128, #0				// expr `ld t100_4, self, 128, 0`
	// assign r6 = `t100_5`
	ld.e r6, r0, #160, #0				// expr `ld t100_5, self, 160, 0`
	// assign r7 = `t100_6`
	ld.e r7, r0, #192, #0				// expr `ld t100_6, self, 192, 0`
	// assign r8 = `t100_7`
	ld.e r8, r0, #224, #0				// expr `ld t100_7, self, 224, 0`
	// assign r9 = `t100_8`
	ld.e r9, r0, #256, #0				// expr `ld t100_8, self, 256, 0`
	// decl `t101_0`: u32
	// decl `t101_1`: u32
	// memsave `t98_2`
	// memsave `t98_3`
	// memsave `t98_4`
	// memsave `t98_5`
	// memsave `t99_0`
	// memsave `t99_1`
	stw.e r3, r31, #96				// memsave r3 => `t100_2`
	stw.e r4, r31, #128				// memsave r4 => `t100_3`
	stw.e r5, r31, #160				// memsave r5 => `t100_4`
	stw.e r6, r31, #192				// memsave r6 => `t100_5`
	// memsave `t101_0`
	// memsave `t101_1`
	// assign r10 = `t101_0`
	mov r30, #0
	bst r10, r30, #0, #0				// expr `bst t101_0, 0, 0, 0`
	// memsave `t98_2`
	// memsave `t98_3`
	// memsave `t98_4`
	// memsave `t98_5`
	// memsave `t99_0`
	// memsave `t99_1`
	stw.e r3, r31, #96				// memsave r3 => `t100_2`
	stw.e r4, r31, #128				// memsave r4 => `t100_3`
	stw.e r5, r31, #160				// memsave r5 => `t100_4`
	stw.e r6, r31, #192				// memsave r6 => `t100_5`
	stw.e r10, r31, #320				// memsave r10 => `t101_0`
	// memsave `t101_1`
	// assign r11 = `t101_1`
	mov r30, #0
	bst r11, r30, #0, #0				// expr `bst t101_1, 0, 0, 0`
	// memsave `t98_0`
	// memsave `t98_1`
	// memsave `t98_2`
	// memsave `t98_3`
	// memsave `t98_4`
	// memsave `t98_5`
	// memsave `t98_6`
	// memsave `t98_7`
	// memsave `t98_8`
	stw.e r1, r31, #32				// memsave r1 => `t100_0`
	stw.e r2, r31, #64				// memsave r2 => `t100_1`
	stw.e r3, r31, #96				// memsave r3 => `t100_2`
	stw.e r4, r31, #128				// memsave r4 => `t100_3`
	stw.e r5, r31, #160				// memsave r5 => `t100_4`
	stw.e r6, r31, #192				// memsave r6 => `t100_5`
	stw.e r7, r31, #224				// memsave r7 => `t100_6`
	stw.e r8, r31, #256				// memsave r8 => `t100_7`
	stw.e r9, r31, #288				// memsave r9 => `t100_8`
	bst r5, r10, #0, #0				// expr `bst t100_4, t101_0, 0, 0`
	bst r6, r11, #0, #0				// expr `bst t100_5, t101_1, 0, 0`
	// undecl `t101_0`
	// undecl `t101_1`
	// undecl `t100_0`
	// undecl `t100_1`
	// undecl `t100_2`
	// undecl `t100_3`
	// undecl `t100_4`
	// undecl `t100_5`
	// undecl `t100_6`
	// undecl `t100_7`
	// undecl `t100_8`
	// decl `t102_0`: u32
	// decl `t102_1`: u32
	// decl `t102_2`: u32
	// decl `t102_3`: u32
	// decl `t102_4`: u32
	// decl `t102_5`: u32
	// decl `t102_6`: u32
	// decl `t102_7`: u32
	// decl `t102_8`: u32
	// memsave `t98_0`
	// memsave `t98_1`
	// memsave `t98_2`
	// memsave `t98_3`
	// memsave `t98_4`
	// memsave `t98_5`
	// memsave `t98_6`
	// memsave `t98_7`
	// memsave `t98_8`
	// memsave `t100_0`
	// memsave `t100_1`
	// memsave `t100_2`
	// memsave `t100_3`
	// memsave `t100_4`
	// memsave `t100_5`
	// memsave `t100_6`
	// memsave `t100_7`
	// memsave `t100_8`
	// memsave `t102_0`
	// memsave `t102_1`
	// memsave `t102_2`
	// memsave `t102_3`
	// memsave `t102_4`
	// memsave `t102_5`
	// memsave `t102_6`
	// memsave `t102_7`
	// memsave `t102_8`
	// assign r1 = `t102_0`
	ld r1, r0, #0, #0				// expr `ld t102_0, self, 0, 0`
	// assign r2 = `t102_1`
	ld.e r2, r0, #32, #0				// expr `ld t102_1, self, 32, 0`
	// assign r3 = `t102_2`
	ld.e r3, r0, #64, #0				// expr `ld t102_2, self, 64, 0`
	// assign r4 = `t102_3`
	ld.e r4, r0, #96, #0				// expr `ld t102_3, self, 96, 0`
	// assign r5 = `t102_4`
	ld.e r5, r0, #128, #0				// expr `ld t102_4, self, 128, 0`
	// assign r6 = `t102_5`
	ld.e r6, r0, #160, #0				// expr `ld t102_5, self, 160, 0`
	// assign r7 = `t102_6`
	ld.e r7, r0, #192, #0				// expr `ld t102_6, self, 192, 0`
	// assign r8 = `t102_7`
	ld.e r8, r0, #224, #0				// expr `ld t102_7, self, 224, 0`
	// assign r9 = `t102_8`
	ld.e r9, r0, #256, #0				// expr `ld t102_8, self, 256, 0`
	// memsave `t98_0`
	// memsave `t98_1`
	// memsave `t98_2`
	// memsave `t98_3`
	// memsave `t98_4`
	// memsave `t98_5`
	// memsave `t98_6`
	// memsave `t98_7`
	// memsave `t98_8`
	// memsave `t100_0`
	// memsave `t100_1`
	// memsave `t100_2`
	// memsave `t100_3`
	// memsave `t100_4`
	// memsave `t100_5`
	// memsave `t100_6`
	// memsave `t100_7`
	// memsave `t100_8`
	stw.e r1, r31, #32				// memsave r1 => `t102_0`
	stw.e r2, r31, #64				// memsave r2 => `t102_1`
	stw.e r3, r31, #96				// memsave r3 => `t102_2`
	stw.e r4, r31, #128				// memsave r4 => `t102_3`
	stw.e r5, r31, #160				// memsave r5 => `t102_4`
	stw.e r6, r31, #192				// memsave r6 => `t102_5`
	stw.e r7, r31, #224				// memsave r7 => `t102_6`
	stw.e r8, r31, #256				// memsave r8 => `t102_7`
	stw.e r9, r31, #288				// memsave r9 => `t102_8`
	mov r30, #0
	bst r7, r30, #0, #8				// expr `bst t102_6, 0, 0, 8`
	// undecl `t102_0`
	// undecl `t102_1`
	// undecl `t102_2`
	// undecl `t102_3`
	// undecl `t102_4`
	// undecl `t102_5`
	// undecl `t102_6`
	// undecl `t102_7`
	// undecl `t102_8`
	// decl `t103_0`: u32
	// decl `t103_1`: u32
	// decl `t103_2`: u32
	// decl `t103_3`: u32
	// decl `t103_4`: u32
	// decl `t103_5`: u32
	// decl `t103_6`: u32
	// decl `t103_7`: u32
	// decl `t103_8`: u32
	// memsave `t98_0`
	// memsave `t98_1`
	// memsave `t98_2`
	// memsave `t98_3`
	// memsave `t98_4`
	// memsave `t98_5`
	// memsave `t98_6`
	// memsave `t98_7`
	// memsave `t98_8`
	// memsave `t100_0`
	// memsave `t100_1`
	// memsave `t100_2`
	// memsave `t100_3`
	// memsave `t100_4`
	// memsave `t100_5`
	// memsave `t100_6`
	// memsave `t100_7`
	// memsave `t100_8`
	// memsave `t102_0`
	// memsave `t102_1`
	// memsave `t102_2`
	// memsave `t102_3`
	// memsave `t102_4`
	// memsave `t102_5`
	// memsave `t102_6`
	// memsave `t102_7`
	// memsave `t102_8`
	// memsave `t103_0`
	// memsave `t103_1`
	// memsave `t103_2`
	// memsave `t103_3`
	// memsave `t103_4`
	// memsave `t103_5`
	// memsave `t103_6`
	// memsave `t103_7`
	// memsave `t103_8`
	// assign r1 = `t103_0`
	ld r1, r0, #0, #0				// expr `ld t103_0, self, 0, 0`
	// assign r2 = `t103_1`
	ld.e r2, r0, #32, #0				// expr `ld t103_1, self, 32, 0`
	// assign r3 = `t103_2`
	ld.e r3, r0, #64, #0				// expr `ld t103_2, self, 64, 0`
	// assign r4 = `t103_3`
	ld.e r4, r0, #96, #0				// expr `ld t103_3, self, 96, 0`
	// assign r5 = `t103_4`
	ld.e r5, r0, #128, #0				// expr `ld t103_4, self, 128, 0`
	// assign r6 = `t103_5`
	ld.e r6, r0, #160, #0				// expr `ld t103_5, self, 160, 0`
	// assign r7 = `t103_6`
	ld.e r7, r0, #192, #0				// expr `ld t103_6, self, 192, 0`
	// assign r8 = `t103_7`
	ld.e r8, r0, #224, #0				// expr `ld t103_7, self, 224, 0`
	// assign r9 = `t103_8`
	ld.e r9, r0, #256, #0				// expr `ld t103_8, self, 256, 0`
	// decl `t104`: u32
	// memsave `t98_7`
	// memsave `t98_8`
	// memsave `t100_7`
	// memsave `t100_8`
	// memsave `t102_7`
	// memsave `t102_8`
	stw.e r8, r31, #256				// memsave r8 => `t103_7`
	stw.e r9, r31, #288				// memsave r9 => `t103_8`
	// memsave `t104`
	// assign r10 = `t104`
	mov.e r30, #255
	bst r10, r30, #16, #8				// expr `bst t104, 255, 16, 8`
	// memsave `t98_7`
	// memsave `t98_8`
	// memsave `t100_7`
	// memsave `t100_8`
	// memsave `t102_7`
	// memsave `t102_8`
	stw.e r8, r31, #256				// memsave r8 => `t103_7`
	stw.e r9, r31, #288				// memsave r9 => `t103_8`
	stw.e r10, r31, #320				// memsave r10 => `t104`
	mov.e r30, #255
	bst r10, r30, #8, #8				// expr `bst t104, 255, 8, 8`
	// memsave `t98_7`
	// memsave `t98_8`
	// memsave `t100_7`
	// memsave `t100_8`
	// memsave `t102_7`
	// memsave `t102_8`
	stw.e r8, r31, #256				// memsave r8 => `t103_7`
	stw.e r9, r31, #288				// memsave r9 => `t103_8`
	stw.e r10, r31, #320				// memsave r10 => `t104`
	mov.e r30, #255
	bst r10, r30, #0, #8				// expr `bst t104, 255, 0, 8`
	// memsave `t98_0`
	// memsave `t98_1`
	// memsave `t98_2`
	// memsave `t98_3`
	// memsave `t98_4`
	// memsave `t98_5`
	// memsave `t98_6`
	// memsave `t98_7`
	// memsave `t98_8`
	// memsave `t100_0`
	// memsave `t100_1`
	// memsave `t100_2`
	// memsave `t100_3`
	// memsave `t100_4`
	// memsave `t100_5`
	// memsave `t100_6`
	// memsave `t100_7`
	// memsave `t100_8`
	// memsave `t102_0`
	// memsave `t102_1`
	// memsave `t102_2`
	// memsave `t102_3`
	// memsave `t102_4`
	// memsave `t102_5`
	// memsave `t102_6`
	// memsave `t102_7`
	// memsave `t102_8`
	stw.e r1, r31, #32				// memsave r1 => `t103_0`
	stw.e r2, r31, #64				// memsave r2 => `t103_1`
	stw.e r3, r31, #96				// memsave r3 => `t103_2`
	stw.e r4, r31, #128				// memsave r4 => `t103_3`
	stw.e r5, r31, #160				// memsave r5 => `t103_4`
	stw.e r6, r31, #192				// memsave r6 => `t103_5`
	stw.e r7, r31, #224				// memsave r7 => `t103_6`
	stw.e r8, r31, #256				// memsave r8 => `t103_7`
	stw.e r9, r31, #288				// memsave r9 => `t103_8`
	bst r8, r10, #0, #0				// expr `bst t103_7, t104, 0, 0`
	// undecl `t104`
	// undecl `t103_0`
	// undecl `t103_1`
	// undecl `t103_2`
	// undecl `t103_3`
	// undecl `t103_4`
	// undecl `t103_5`
	// undecl `t103_6`
	// undecl `t103_7`
	// undecl `t103_8`
	// decl `t105_0`: u32
	// decl `t105_1`: u32
	// decl `t105_2`: u32
	// decl `t105_3`: u32
	// decl `t105_4`: u32
	// decl `t105_5`: u32
	// decl `t105_6`: u32
	// decl `t105_7`: u32
	// decl `t105_8`: u32
	// memsave `t98_0`
	// memsave `t98_1`
	// memsave `t98_2`
	// memsave `t98_3`
	// memsave `t98_4`
	// memsave `t98_5`
	// memsave `t98_6`
	// memsave `t98_7`
	// memsave `t98_8`
	// memsave `t100_0`
	// memsave `t100_1`
	// memsave `t100_2`
	// memsave `t100_3`
	// memsave `t100_4`
	// memsave `t100_5`
	// memsave `t100_6`
	// memsave `t100_7`
	// memsave `t100_8`
	// memsave `t102_0`
	// memsave `t102_1`
	// memsave `t102_2`
	// memsave `t102_3`
	// memsave `t102_4`
	// memsave `t102_5`
	// memsave `t102_6`
	// memsave `t102_7`
	// memsave `t102_8`
	// memsave `t103_0`
	// memsave `t103_1`
	// memsave `t103_2`
	// memsave `t103_3`
	// memsave `t103_4`
	// memsave `t103_5`
	// memsave `t103_6`
	// memsave `t103_7`
	// memsave `t103_8`
	// memsave `t105_0`
	// memsave `t105_1`
	// memsave `t105_2`
	// memsave `t105_3`
	// memsave `t105_4`
	// memsave `t105_5`
	// memsave `t105_6`
	// memsave `t105_7`
	// memsave `t105_8`
	// assign r1 = `t105_0`
	ld r1, r0, #0, #0				// expr `ld t105_0, self, 0, 0`
	// assign r2 = `t105_1`
	ld.e r2, r0, #32, #0				// expr `ld t105_1, self, 32, 0`
	// assign r3 = `t105_2`
	ld.e r3, r0, #64, #0				// expr `ld t105_2, self, 64, 0`
	// assign r4 = `t105_3`
	ld.e r4, r0, #96, #0				// expr `ld t105_3, self, 96, 0`
	// assign r5 = `t105_4`
	ld.e r5, r0, #128, #0				// expr `ld t105_4, self, 128, 0`
	// assign r6 = `t105_5`
	ld.e r6, r0, #160, #0				// expr `ld t105_5, self, 160, 0`
	// assign r7 = `t105_6`
	ld.e r7, r0, #192, #0				// expr `ld t105_6, self, 192, 0`
	// assign r8 = `t105_7`
	ld.e r8, r0, #224, #0				// expr `ld t105_7, self, 224, 0`
	// assign r9 = `t105_8`
	ld.e r9, r0, #256, #0				// expr `ld t105_8, self, 256, 0`
	// undecl `self`
	// decl `t106`: u32
	// memsave `t98_7`
	// memsave `t98_8`
	// memsave `t100_7`
	// memsave `t100_8`
	// memsave `t102_7`
	// memsave `t102_8`
	// memsave `t103_7`
	// memsave `t103_8`
	// memsave `t104`
	stw.e r8, r31, #256				// memsave r8 => `t105_7`
	stw.e r9, r31, #288				// memsave r9 => `t105_8`
	// memsave `t106`
	// assign r0 = `t106`
	mov r30, #0
	bst r0, r30, #16, #8				// expr `bst t106, 0, 16, 8`
	// memsave `t98_7`
	// memsave `t98_8`
	// memsave `t100_7`
	// memsave `t100_8`
	// memsave `t102_7`
	// memsave `t102_8`
	// memsave `t103_7`
	// memsave `t103_8`
	// memsave `t104`
	stw.e r8, r31, #256				// memsave r8 => `t105_7`
	stw.e r9, r31, #288				// memsave r9 => `t105_8`
	stw r0, r31, #0				// memsave r0 => `t106`
	mov r30, #0
	bst r0, r30, #8, #8				// expr `bst t106, 0, 8, 8`
	// memsave `t98_7`
	// memsave `t98_8`
	// memsave `t100_7`
	// memsave `t100_8`
	// memsave `t102_7`
	// memsave `t102_8`
	// memsave `t103_7`
	// memsave `t103_8`
	// memsave `t104`
	stw.e r8, r31, #256				// memsave r8 => `t105_7`
	stw.e r9, r31, #288				// memsave r9 => `t105_8`
	stw r0, r31, #0				// memsave r0 => `t106`
	mov r30, #0
	bst r0, r30, #0, #8				// expr `bst t106, 0, 0, 8`
	// memsave `t98_0`
	// memsave `t98_1`
	// memsave `t98_2`
	// memsave `t98_3`
	// memsave `t98_4`
	// memsave `t98_5`
	// memsave `t98_6`
	// memsave `t98_7`
	// memsave `t98_8`
	// memsave `t100_0`
	// memsave `t100_1`
	// memsave `t100_2`
	// memsave `t100_3`
	// memsave `t100_4`
	// memsave `t100_5`
	// memsave `t100_6`
	// memsave `t100_7`
	// memsave `t100_8`
	// memsave `t102_0`
	// memsave `t102_1`
	// memsave `t102_2`
	// memsave `t102_3`
	// memsave `t102_4`
	// memsave `t102_5`
	// memsave `t102_6`
	// memsave `t102_7`
	// memsave `t102_8`
	// memsave `t103_0`
	// memsave `t103_1`
	// memsave `t103_2`
	// memsave `t103_3`
	// memsave `t103_4`
	// memsave `t103_5`
	// memsave `t103_6`
	// memsave `t103_7`
	// memsave `t103_8`
	stw.e r1, r31, #32				// memsave r1 => `t105_0`
	stw.e r2, r31, #64				// memsave r2 => `t105_1`
	stw.e r3, r31, #96				// memsave r3 => `t105_2`
	stw.e r4, r31, #128				// memsave r4 => `t105_3`
	stw.e r5, r31, #160				// memsave r5 => `t105_4`
	stw.e r6, r31, #192				// memsave r6 => `t105_5`
	stw.e r7, r31, #224				// memsave r7 => `t105_6`
	stw.e r8, r31, #256				// memsave r8 => `t105_7`
	stw.e r9, r31, #288				// memsave r9 => `t105_8`
	bst r9, r0, #0, #0				// expr `bst t105_8, t106, 0, 0`
	// undecl `t106`
	// undecl `t105_0`
	// undecl `t105_1`
	// undecl `t105_2`
	// undecl `t105_3`
	// undecl `t105_4`
	// undecl `t105_5`
	// undecl `t105_6`
	// undecl `t105_7`
	// undecl `t105_8`

//
// u_RenderState____Draw
// args: self
//

// stack is []
// from _Main__:
_u_RenderState____Draw__:
	// expr `argld self, 0`
	// decl `t107_0`: u32
	// decl `t107_1`: u32
	// decl `t107_2`: u32
	// decl `t107_3`: u32
	// decl `t107_4`: u32
	// decl `t107_5`: u32
	// decl `t107_6`: u32
	// decl `t107_7`: u32
	// decl `t107_8`: u32
	// memsave `t107_0`
	// memsave `t107_1`
	// memsave `t107_2`
	// memsave `t107_3`
	// memsave `t107_4`
	// memsave `t107_5`
	// memsave `t107_6`
	// memsave `t107_7`
	// memsave `t107_8`
	// assign r1 = `t107_0`
	ld r1, r0, #0, #0				// expr `ld t107_0, self, 0, 0`
	// assign r2 = `t107_1`
	ld.e r2, r0, #32, #0				// expr `ld t107_1, self, 32, 0`
	// assign r3 = `t107_2`
	ld.e r3, r0, #64, #0				// expr `ld t107_2, self, 64, 0`
	// assign r4 = `t107_3`
	ld.e r4, r0, #96, #0				// expr `ld t107_3, self, 96, 0`
	// assign r5 = `t107_4`
	ld.e r5, r0, #128, #0				// expr `ld t107_4, self, 128, 0`
	// assign r6 = `t107_5`
	ld.e r6, r0, #160, #0				// expr `ld t107_5, self, 160, 0`
	// assign r7 = `t107_6`
	ld.e r7, r0, #192, #0				// expr `ld t107_6, self, 192, 0`
	// assign r8 = `t107_7`
	ld.e r8, r0, #224, #0				// expr `ld t107_7, self, 224, 0`
	// assign r9 = `t107_8`
	ld.e r9, r0, #256, #0				// expr `ld t107_8, self, 256, 0`
	// decl `t108_0`: u32
	// decl `t108_1`: u32
	// assign r10 = `t108_0`
	bsf r10, r3, #0, #0				// expr `bsf t108_0, t107_2, 0, 0`
	// assign r11 = `t108_1`
	bsf r11, r4, #0, #0				// expr `bsf t108_1, t107_3, 0, 0`
	// undecl `t107_0`
	// undecl `t107_1`
	// undecl `t107_2`
	// undecl `t107_3`
	// undecl `t107_4`
	// undecl `t107_5`
	// undecl `t107_6`
	// undecl `t107_7`
	// undecl `t107_8`
	// decl `t109`: u32
	// assign r1 = `t109`
	bsf r1, r11, #0, #0				// expr `bsf t109, t108_1, 0, 0`
	// undecl `t108_0`
	// undecl `t108_1`
	// decl `latScroll`: u32
	// assign r2 = `latScroll`
	mov r2, r1				// expr `mov latScroll, t109`
	// undecl `t109`
	// decl `row`: u32
	// assign r1 = `row`
	mov r30, #0
	mov r1, r30				// expr `mov row, 0`

// expecting `r0` = `self`
// expecting `r1` = `row`
// expecting `r2` = `latScroll`
// stack is [`self`, `row`, `latScroll`]
// from _u_RenderState____Draw__:
L110:
	ult r1, #24				// expr `ult row, 24`
	c.jmp L111:				// expr `c.jmp L111:`

// expecting `r0` = `self`
// expecting `r1` = `row`
// expecting `r2` = `latScroll`
// stack is [`self`, `row`, `latScroll`]
// from L110:
_L113:
	// undecl `latScroll`
	// undecl `row`
	jmp L112:				// expr `jmp L112:`

// expecting `r0` = `self`
// expecting `r1` = `row`
// expecting `r2` = `latScroll`
// stack is [`self`, `row`, `latScroll`]
// from L110:
L111:
	// decl `t115_0`: u32
	// decl `t115_1`: u32
	// decl `t115_2`: u32
	// decl `t115_3`: u32
	// decl `t115_4`: u32
	// decl `t115_5`: u32
	// decl `t115_6`: u32
	// decl `t115_7`: u32
	// decl `t115_8`: u32
	// memsave `t115_0`
	// memsave `t115_1`
	// memsave `t115_2`
	// memsave `t115_3`
	// memsave `t115_4`
	// memsave `t115_5`
	// memsave `t115_6`
	// memsave `t115_7`
	// memsave `t115_8`
	// memsave `t107_0`
	// memsave `t107_1`
	// memsave `t107_2`
	// memsave `t107_3`
	// memsave `t107_4`
	// memsave `t107_5`
	// memsave `t107_6`
	// memsave `t107_7`
	// memsave `t107_8`
	// assign r3 = `t115_0`
	ld r3, r0, #0, #0				// expr `ld t115_0, self, 0, 0`
	// assign r4 = `t115_1`
	ld.e r4, r0, #32, #0				// expr `ld t115_1, self, 32, 0`
	// assign r5 = `t115_2`
	ld.e r5, r0, #64, #0				// expr `ld t115_2, self, 64, 0`
	// assign r6 = `t115_3`
	ld.e r6, r0, #96, #0				// expr `ld t115_3, self, 96, 0`
	// assign r7 = `t115_4`
	ld.e r7, r0, #128, #0				// expr `ld t115_4, self, 128, 0`
	// assign r8 = `t115_5`
	ld.e r8, r0, #160, #0				// expr `ld t115_5, self, 160, 0`
	// assign r9 = `t115_6`
	ld.e r9, r0, #192, #0				// expr `ld t115_6, self, 192, 0`
	// assign r10 = `t115_7`
	ld.e r10, r0, #224, #0				// expr `ld t115_7, self, 224, 0`
	// assign r11 = `t115_8`
	ld.e r11, r0, #256, #0				// expr `ld t115_8, self, 256, 0`
	// alloc `t116`: u32[24]
	// assign r12 = `t116`
	bsf r12, r4, #0, #0				// expr `bsf t116, t115_1, 0, 0`
	// undecl `t115_0`
	// undecl `t115_1`
	// undecl `t115_2`
	// undecl `t115_3`
	// undecl `t115_4`
	// undecl `t115_5`
	// undecl `t115_6`
	// undecl `t115_7`
	// undecl `t115_8`
	// decl `t117`: u32
	// assign r3 = `t117`
	mul.e r3, r1, #32				// expr `mul t117, row, 32`
	// decl `t118`: u32
	// memsave `t115_0`
	// memsave `t118`
	// memsave `t107_0`
	// assign r4 = `t118`
	ldw r4, r12, r3				// expr `ldw t118, t116, t117`
	// undecl `t117`
	// undecl `t116`
	// decl `linePtr`: u32
	// assign r3 = `linePtr`
	mov r3, r4				// expr `mov linePtr, t118`
	// undecl `t118`
	// decl `col`: u32
	// assign r4 = `col`
	mov r30, #0
	mov r4, r30				// expr `mov col, 0`

// expecting `r0` = `self`
// expecting `r1` = `row`
// expecting `r2` = `latScroll`
// expecting `r3` = `linePtr`
// expecting `r4` = `col`
// stack is [`self`, `row`, `latScroll`, `linePtr`, `col`, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, `_ARRAY_t116`]
// from L111:
L119:
	ult.e r4, #64				// expr `ult col, 64`
	c.jmp L120:				// expr `c.jmp L120:`

// expecting `r0` = `self`
// expecting `r1` = `row`
// expecting `r2` = `latScroll`
// expecting `r3` = `linePtr`
// expecting `r4` = `col`
// stack is [`self`, `row`, `latScroll`, `linePtr`, `col`, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, `_ARRAY_t116`]
// from L119:
_L122:
	// undecl `linePtr`
	// undecl `col`
	jmp L121:				// expr `jmp L121:`

// expecting `r0` = `self`
// expecting `r1` = `row`
// expecting `r2` = `latScroll`
// expecting `r3` = `linePtr`
// expecting `r4` = `col`
// stack is [`self`, `row`, `latScroll`, `linePtr`, `col`, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, `_ARRAY_t116`]
// from L119:
L120:
	// decl `t124`: u32
	// assign r5 = `t124`
	add r5, r4, r2				// expr `add t124, col, latScroll`
	// decl `t125`: u32
	// assign r6 = `t125`
	mul.e r6, r5, #32				// expr `mul t125, t124, 32`
	// undecl `t124`
	// decl `t126`: u8
	// memsave `t126`
	// memsave `t115_6`
	// memsave `t115_7`
	// memsave `t115_7`
	// memsave `t115_7`
	// memsave `t115_8`
	// memsave `t115_8`
	// memsave `t115_8`
	// memsave `t107_6`
	// memsave `t107_7`
	// memsave `t107_7`
	// memsave `t107_7`
	// memsave `t107_8`
	// memsave `t107_8`
	// memsave `t107_8`
	// assign r5 = `t126`
	ldw r5, r3, r6				// expr `ldw t126, linePtr, t125`
	// undecl `t125`
	// decl `char`: u8
	// assign r6 = `char`
	mov r6, r5				// expr `mov char, t126`
	// undecl `t126`
	eq r6, #10				// expr `eq char, 10`
	c.jmp L127:				// expr `c.jmp L127:`

// expecting `r0` = `self`
// expecting `r1` = `row`
// expecting `r2` = `latScroll`
// expecting `r3` = `linePtr`
// expecting `r4` = `col`
// expecting `r6` = `char`
// stack is [`self`, `row`, `latScroll`, `linePtr`, `col`, `char`, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, `_ARRAY_t116`]
// from L120:
_L130:
	jmp L129:				// expr `jmp L129:`

// expecting `r0` = `self`
// expecting `r1` = `row`
// expecting `r2` = `latScroll`
// expecting `r3` = `linePtr`
// expecting `r4` = `col`
// expecting `r6` = `char`
// stack is [`self`, `row`, `latScroll`, `linePtr`, `col`, `char`, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, `_ARRAY_t116`]
// from _L130:
L129:
	eq r6, #0				// expr `eq char, 0`
	// prepare state for L127:
	c.jmp L127:				// expr `c.jmp L127:`

// expecting `r0` = `self`
// expecting `r1` = `row`
// expecting `r2` = `latScroll`
// expecting `r3` = `linePtr`
// expecting `r4` = `col`
// expecting `r6` = `char`
// stack is [`self`, `row`, `latScroll`, `linePtr`, `col`, `char`, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, `_ARRAY_t116`]
// from L129:
_L132:
	jmp L128:				// expr `jmp L128:`

// expecting `r0` = `self`
// expecting `r1` = `row`
// expecting `r2` = `latScroll`
// expecting `r3` = `linePtr`
// expecting `r4` = `col`
// expecting `r6` = `char`
// stack is [`self`, `row`, `latScroll`, `linePtr`, `col`, `char`, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, `_ARRAY_t116`]
// from L120:
L127:
	// undecl `char`
	// undecl `linePtr`

// expecting `r0` = `self`
// expecting `r1` = `row`
// expecting `r2` = `latScroll`
// expecting `r4` = `col`
// stack is [`self`, `row`, `latScroll`, empty, `col`, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, `_ARRAY_t116`]
// from L127:
L134:
	ult.e r4, #64				// expr `ult col, 64`
	c.jmp L135:				// expr `c.jmp L135:`

// expecting `r0` = `self`
// expecting `r1` = `row`
// expecting `r2` = `latScroll`
// expecting `r4` = `col`
// stack is [`self`, `row`, `latScroll`, empty, `col`, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, `_ARRAY_t116`]
// from L134:
_L137:
	// undecl `col`
	jmp L136:				// expr `jmp L136:`

// expecting `r0` = `self`
// expecting `r1` = `row`
// expecting `r2` = `latScroll`
// expecting `r4` = `col`
// stack is [`self`, `row`, `latScroll`, empty, `col`, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, `_ARRAY_t116`]
// from L134:
L135:
	// expr `argst 0, self`
	stw.e r1, r31, #32
	mov r1, #0				// expr `argst 1, 0`
	stw.e r2, r31, #64				// clobbering r2 (`latScroll`)
	ldw.e r2, r31, #32				// assign r2 = `row`	// expr `argst 2, row`
	mov r3, r4				// assign r3 = `col`	// expr `argst 3, col`
	stw r0, r31, #0
	stw.e r2, r31, #32
	stw.e r3, r31, #128
	stw.e r4, r31, #128
	add.e r31, r31, #1088
	call _u_RenderState____WriteChar__:
	sub.e r31, r31, #1088				// expr `call u_RenderState____WriteChar`
	// decl `t140`: u32
	// assign r0 = `t140`
	ldw.e r1, r31, #128				// assign r1 = `col`
	add r0, r1, #1				// expr `add t140, col, 1`
	mov r1, r0				// expr `mov col, t140`
	// undecl `t140`
	// prepare state for L134:
	ldw r0, r31, #0
	stw.e r1, r31, #128
	ldw.e r2, r31, #64
	ldw.e r4, r31, #128
	jmp L134:				// expr `jmp L134:`

// expecting `r0` = `self`
// expecting `r1` = `row`
// expecting `r2` = `latScroll`
// stack is [`self`, `row`, `latScroll`, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, `_ARRAY_t116`]
// from _L137:
L136:
	// prepare state for L121:
	jmp L121:				// expr `jmp L121:`

// expecting `r0` = `self`
// expecting `r1` = `row`
// expecting `r2` = `latScroll`
// expecting `r3` = `linePtr`
// expecting `r4` = `col`
// expecting `r6` = `char`
// stack is [`self`, `row`, `latScroll`, `linePtr`, `col`, `char`, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, `_ARRAY_t116`]
// from _L132:
L128:
	// expr `argst 0, self`
	stw.e r1, r31, #32				// clobbering r1 (`row`)
	mov r1, r6				// assign r1 = `char`	// expr `argst 1, char`
	// undecl `char`
	stw.e r2, r31, #64				// clobbering r2 (`latScroll`)
	ldw.e r2, r31, #32				// assign r2 = `row`	// expr `argst 2, row`
	stw.e r3, r31, #96				// clobbering r3 (`linePtr`)
	mov r3, r4				// assign r3 = `col`	// expr `argst 3, col`
	stw r0, r31, #0
	stw.e r2, r31, #32
	stw.e r3, r31, #128
	stw.e r4, r31, #128
	add.e r31, r31, #1088
	call _u_RenderState____WriteChar__:
	sub.e r31, r31, #1088				// expr `call u_RenderState____WriteChar`
	// decl `t144`: u32
	// assign r0 = `t144`
	ldw.e r1, r31, #128				// assign r1 = `col`
	add r0, r1, #1				// expr `add t144, col, 1`
	mov r1, r0				// expr `mov col, t144`
	// undecl `t144`
	// prepare state for L119:
	ldw r0, r31, #0
	stw.e r1, r31, #128
	ldw.e r2, r31, #64
	ldw.e r3, r31, #96
	ldw.e r4, r31, #128
	jmp L119:				// expr `jmp L119:`

// expecting `r0` = `self`
// expecting `r1` = `row`
// expecting `r2` = `latScroll`
// stack is [`self`, `row`, `latScroll`, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, empty, `_ARRAY_t116`]
// from _L122:
L121:
	// decl `t146`: u32
	// assign r3 = `t146`
	add r3, r1, #1				// expr `add t146, row, 1`
	mov r1, r3				// expr `mov row, t146`
	// undecl `t146`
	// prepare state for L110:
	jmp L110:				// expr `jmp L110:`

// expecting `r0` = `self`
// stack is [`self`]
// from _L113:
L112:
	// decl `t148_0`: u32
	// decl `t148_1`: u32
	// decl `t148_2`: u32
	// decl `t148_3`: u32
	// decl `t148_4`: u32
	// decl `t148_5`: u32
	// decl `t148_6`: u32
	// decl `t148_7`: u32
	// decl `t148_8`: u32
	// memsave `t107_0`
	// memsave `t107_1`
	// memsave `t107_2`
	// memsave `t107_3`
	// memsave `t107_4`
	// memsave `t107_5`
	// memsave `t107_6`
	// memsave `t107_7`
	// memsave `t107_8`
	// memsave `t148_0`
	// memsave `t148_1`
	// memsave `t148_2`
	// memsave `t148_3`
	// memsave `t148_4`
	// memsave `t148_5`
	// memsave `t148_6`
	// memsave `t148_7`
	// memsave `t148_8`
	// assign r1 = `t148_0`
	ld r1, r0, #0, #0				// expr `ld t148_0, self, 0, 0`
	// assign r2 = `t148_1`
	ld.e r2, r0, #32, #0				// expr `ld t148_1, self, 32, 0`
	// assign r3 = `t148_2`
	ld.e r3, r0, #64, #0				// expr `ld t148_2, self, 64, 0`
	// assign r4 = `t148_3`
	ld.e r4, r0, #96, #0				// expr `ld t148_3, self, 96, 0`
	// assign r5 = `t148_4`
	ld.e r5, r0, #128, #0				// expr `ld t148_4, self, 128, 0`
	// assign r6 = `t148_5`
	ld.e r6, r0, #160, #0				// expr `ld t148_5, self, 160, 0`
	// assign r7 = `t148_6`
	ld.e r7, r0, #192, #0				// expr `ld t148_6, self, 192, 0`
	// assign r8 = `t148_7`
	ld.e r8, r0, #224, #0				// expr `ld t148_7, self, 224, 0`
	// assign r9 = `t148_8`
	ld.e r9, r0, #256, #0				// expr `ld t148_8, self, 256, 0`
	// decl `t149_0`: u32
	// decl `t149_1`: u32
	// decl `t149_2`: u32
	// decl `t149_3`: u32
	// decl `t149_4`: u32
	// decl `t149_5`: u32
	// decl `t149_6`: u32
	// decl `t149_7`: u32
	// decl `t149_8`: u32
	// memsave `t107_0`
	// memsave `t107_1`
	// memsave `t107_2`
	// memsave `t107_3`
	// memsave `t107_4`
	// memsave `t107_5`
	// memsave `t107_6`
	// memsave `t107_7`
	// memsave `t107_8`
	stw.e r1, r31, #32				// memsave r1 => `t148_0`
	stw.e r2, r31, #64				// memsave r2 => `t148_1`
	stw.e r3, r31, #96				// memsave r3 => `t148_2`
	stw.e r4, r31, #128				// memsave r4 => `t148_3`
	stw.e r5, r31, #160				// memsave r5 => `t148_4`
	stw.e r6, r31, #192				// memsave r6 => `t148_5`
	stw.e r7, r31, #224				// memsave r7 => `t148_6`
	stw.e r8, r31, #256				// memsave r8 => `t148_7`
	stw.e r9, r31, #288				// memsave r9 => `t148_8`
	// memsave `t149_0`
	// memsave `t149_1`
	// memsave `t149_2`
	// memsave `t149_3`
	// memsave `t149_4`
	// memsave `t149_5`
	// memsave `t149_6`
	// memsave `t149_7`
	// memsave `t149_8`
	// assign r10 = `t149_0`
	ld r10, r0, #0, #0				// expr `ld t149_0, self, 0, 0`
	// assign r11 = `t149_1`
	ld.e r11, r0, #32, #0				// expr `ld t149_1, self, 32, 0`
	// assign r12 = `t149_2`
	ld.e r12, r0, #64, #0				// expr `ld t149_2, self, 64, 0`
	// assign r13 = `t149_3`
	ld.e r13, r0, #96, #0				// expr `ld t149_3, self, 96, 0`
	// assign r14 = `t149_4`
	ld.e r14, r0, #128, #0				// expr `ld t149_4, self, 128, 0`
	// assign r15 = `t149_5`
	ld.e r15, r0, #160, #0				// expr `ld t149_5, self, 160, 0`
	// assign r16 = `t149_6`
	ld.e r16, r0, #192, #0				// expr `ld t149_6, self, 192, 0`
	// assign r17 = `t149_7`
	ld.e r17, r0, #224, #0				// expr `ld t149_7, self, 224, 0`
	// assign r18 = `t149_8`
	ld.e r18, r0, #256, #0				// expr `ld t149_8, self, 256, 0`
	// undecl `self`
	// decl `t150`: u8
	// assign r0 = `t150`
	bsf r0, r16, #0, #8				// expr `bsf t150, t149_6, 0, 8`
	// undecl `t149_0`
	// undecl `t149_1`
	// undecl `t149_2`
	// undecl `t149_3`
	// undecl `t149_4`
	// undecl `t149_5`
	// undecl `t149_6`
	// undecl `t149_7`
	// undecl `t149_8`
	// decl `t151`: u8
	// assign r10 = `t151`
	add r10, r0, #1				// expr `add t151, t150, 1`
	// undecl `t150`
	// memsave `t107_0`
	// memsave `t107_1`
	// memsave `t107_2`
	// memsave `t107_3`
	// memsave `t107_4`
	// memsave `t107_5`
	// memsave `t107_6`
	// memsave `t107_7`
	// memsave `t107_8`
	stw.e r1, r31, #32				// memsave r1 => `t148_0`
	stw.e r2, r31, #64				// memsave r2 => `t148_1`
	stw.e r3, r31, #96				// memsave r3 => `t148_2`
	stw.e r4, r31, #128				// memsave r4 => `t148_3`
	stw.e r5, r31, #160				// memsave r5 => `t148_4`
	stw.e r6, r31, #192				// memsave r6 => `t148_5`
	stw.e r7, r31, #224				// memsave r7 => `t148_6`
	stw.e r8, r31, #256				// memsave r8 => `t148_7`
	stw.e r9, r31, #288				// memsave r9 => `t148_8`
	// memsave `t149_0`
	// memsave `t149_1`
	// memsave `t149_2`
	// memsave `t149_3`
	// memsave `t149_4`
	// memsave `t149_5`
	// memsave `t149_6`
	// memsave `t149_7`
	// memsave `t149_8`
	bst r7, r10, #0, #8				// expr `bst t148_6, t151, 0, 8`
	// undecl `t151`
	// undecl `t148_0`
	// undecl `t148_1`
	// undecl `t148_2`
	// undecl `t148_3`
	// undecl `t148_4`
	// undecl `t148_5`
	// undecl `t148_6`
	// undecl `t148_7`
	// undecl `t148_8`

//
// u_RenderState____WriteChar
// args: self, char, row, col
//

// stack is []
// from L135:
_u_RenderState____WriteChar__:
	// expr `argld self, 0`
	// expr `argld char, 1`
	// expr `argld row, 2`
	// expr `argld col, 3`
	// decl `t152_0`: u32
	// decl `t152_1`: u32
	// decl `t152_2`: u32
	// decl `t152_3`: u32
	// decl `t152_4`: u32
	// decl `t152_5`: u32
	// decl `t152_6`: u32
	// decl `t152_7`: u32
	// decl `t152_8`: u32
	// memsave `t152_0`
	// memsave `t152_1`
	// memsave `t152_2`
	// memsave `t152_3`
	// memsave `t152_4`
	// memsave `t152_5`
	// memsave `t152_6`
	// memsave `t152_7`
	// memsave `t152_8`
	// assign r4 = `t152_0`
	ld r4, r0, #0, #0				// expr `ld t152_0, self, 0, 0`
	// assign r5 = `t152_1`
	ld.e r5, r0, #32, #0				// expr `ld t152_1, self, 32, 0`
	// assign r6 = `t152_2`
	ld.e r6, r0, #64, #0				// expr `ld t152_2, self, 64, 0`
	// assign r7 = `t152_3`
	ld.e r7, r0, #96, #0				// expr `ld t152_3, self, 96, 0`
	// assign r8 = `t152_4`
	ld.e r8, r0, #128, #0				// expr `ld t152_4, self, 128, 0`
	// assign r9 = `t152_5`
	ld.e r9, r0, #160, #0				// expr `ld t152_5, self, 160, 0`
	// assign r10 = `t152_6`
	ld.e r10, r0, #192, #0				// expr `ld t152_6, self, 192, 0`
	// assign r11 = `t152_7`
	ld.e r11, r0, #224, #0				// expr `ld t152_7, self, 224, 0`
	// assign r12 = `t152_8`
	ld.e r12, r0, #256, #0				// expr `ld t152_8, self, 256, 0`
	// decl `t153`: u32
	// assign r13 = `t153`
	bsf r13, r11, #0, #0				// expr `bsf t153, t152_7, 0, 0`
	// undecl `t152_0`
	// undecl `t152_1`
	// undecl `t152_2`
	// undecl `t152_3`
	// undecl `t152_4`
	// undecl `t152_5`
	// undecl `t152_6`
	// undecl `t152_7`
	// undecl `t152_8`
	// decl `fore`: u32
	// assign r4 = `fore`
	mov r4, r13				// expr `mov fore, t153`
	// undecl `t153`
	// decl `t154_0`: u32
	// decl `t154_1`: u32
	// decl `t154_2`: u32
	// decl `t154_3`: u32
	// decl `t154_4`: u32
	// decl `t154_5`: u32
	// decl `t154_6`: u32
	// decl `t154_7`: u32
	// decl `t154_8`: u32
	// memsave `t152_0`
	// memsave `t152_1`
	// memsave `t152_2`
	// memsave `t152_3`
	// memsave `t152_4`
	// memsave `t152_5`
	// memsave `t152_6`
	// memsave `t152_7`
	// memsave `t152_8`
	// memsave `t154_0`
	// memsave `t154_1`
	// memsave `t154_2`
	// memsave `t154_3`
	// memsave `t154_4`
	// memsave `t154_5`
	// memsave `t154_6`
	// memsave `t154_7`
	// memsave `t154_8`
	// assign r5 = `t154_0`
	ld r5, r0, #0, #0				// expr `ld t154_0, self, 0, 0`
	// assign r6 = `t154_1`
	ld.e r6, r0, #32, #0				// expr `ld t154_1, self, 32, 0`
	// assign r7 = `t154_2`
	ld.e r7, r0, #64, #0				// expr `ld t154_2, self, 64, 0`
	// assign r8 = `t154_3`
	ld.e r8, r0, #96, #0				// expr `ld t154_3, self, 96, 0`
	// assign r9 = `t154_4`
	ld.e r9, r0, #128, #0				// expr `ld t154_4, self, 128, 0`
	// assign r10 = `t154_5`
	ld.e r10, r0, #160, #0				// expr `ld t154_5, self, 160, 0`
	// assign r11 = `t154_6`
	ld.e r11, r0, #192, #0				// expr `ld t154_6, self, 192, 0`
	// assign r12 = `t154_7`
	ld.e r12, r0, #224, #0				// expr `ld t154_7, self, 224, 0`
	// assign r13 = `t154_8`
	ld.e r13, r0, #256, #0				// expr `ld t154_8, self, 256, 0`
	// decl `t155`: u32
	// assign r14 = `t155`
	bsf r14, r13, #0, #0				// expr `bsf t155, t154_8, 0, 0`
	// undecl `t154_0`
	// undecl `t154_1`
	// undecl `t154_2`
	// undecl `t154_3`
	// undecl `t154_4`
	// undecl `t154_5`
	// undecl `t154_6`
	// undecl `t154_7`
	// undecl `t154_8`
	// decl `back`: u32
	// assign r5 = `back`
	mov r5, r14				// expr `mov back, t155`
	// undecl `t155`
	// decl `t160_0`: u32
	// decl `t160_1`: u32
	// decl `t160_2`: u32
	// decl `t160_3`: u32
	// decl `t160_4`: u32
	// decl `t160_5`: u32
	// decl `t160_6`: u32
	// decl `t160_7`: u32
	// decl `t160_8`: u32
	// memsave `t152_0`
	// memsave `t152_1`
	// memsave `t152_2`
	// memsave `t152_3`
	// memsave `t152_4`
	// memsave `t152_5`
	// memsave `t152_6`
	// memsave `t152_7`
	// memsave `t152_8`
	// memsave `t154_0`
	// memsave `t154_1`
	// memsave `t154_2`
	// memsave `t154_3`
	// memsave `t154_4`
	// memsave `t154_5`
	// memsave `t154_6`
	// memsave `t154_7`
	// memsave `t154_8`
	// memsave `t160_0`
	// memsave `t160_1`
	// memsave `t160_2`
	// memsave `t160_3`
	// memsave `t160_4`
	// memsave `t160_5`
	// memsave `t160_6`
	// memsave `t160_7`
	// memsave `t160_8`
	// assign r6 = `t160_0`
	ld r6, r0, #0, #0				// expr `ld t160_0, self, 0, 0`
	// assign r7 = `t160_1`
	ld.e r7, r0, #32, #0				// expr `ld t160_1, self, 32, 0`
	// assign r8 = `t160_2`
	ld.e r8, r0, #64, #0				// expr `ld t160_2, self, 64, 0`
	// assign r9 = `t160_3`
	ld.e r9, r0, #96, #0				// expr `ld t160_3, self, 96, 0`
	// assign r10 = `t160_4`
	ld.e r10, r0, #128, #0				// expr `ld t160_4, self, 128, 0`
	// assign r11 = `t160_5`
	ld.e r11, r0, #160, #0				// expr `ld t160_5, self, 160, 0`
	// assign r12 = `t160_6`
	ld.e r12, r0, #192, #0				// expr `ld t160_6, self, 192, 0`
	// assign r13 = `t160_7`
	ld.e r13, r0, #224, #0				// expr `ld t160_7, self, 224, 0`
	// assign r14 = `t160_8`
	ld.e r14, r0, #256, #0				// expr `ld t160_8, self, 256, 0`
	// decl `t161_0`: u32
	// decl `t161_1`: u32
	// assign r15 = `t161_0`
	bsf r15, r10, #0, #0				// expr `bsf t161_0, t160_4, 0, 0`
	// assign r16 = `t161_1`
	bsf r16, r11, #0, #0				// expr `bsf t161_1, t160_5, 0, 0`
	// undecl `t160_0`
	// undecl `t160_1`
	// undecl `t160_2`
	// undecl `t160_3`
	// undecl `t160_4`
	// undecl `t160_5`
	// undecl `t160_6`
	// undecl `t160_7`
	// undecl `t160_8`
	// decl `t162`: u32
	// assign r6 = `t162`
	bsf r6, r16, #0, #0				// expr `bsf t162, t161_1, 0, 0`
	// undecl `t161_0`
	// undecl `t161_1`
	eq r2, r6				// expr `eq row, t162`
	// undecl `t162`
	c.jmp L159:				// expr `c.jmp L159:`

// expecting `r0` = `self`
// expecting `r1` = `char`
// expecting `r2` = `row`
// expecting `r3` = `col`
// expecting `r4` = `fore`
// expecting `r5` = `back`
// stack is [`self`, `char`, `row`, `col`, `fore`, `back`]
// from _u_RenderState____WriteChar__:
_L163:
	// undecl `self`
	jmp L157:				// expr `jmp L157:`

// expecting `r0` = `self`
// expecting `r1` = `char`
// expecting `r2` = `row`
// expecting `r3` = `col`
// expecting `r4` = `fore`
// expecting `r5` = `back`
// stack is [`self`, `char`, `row`, `col`, `fore`, `back`]
// from _u_RenderState____WriteChar__:
L159:
	// decl `t165_0`: u32
	// decl `t165_1`: u32
	// decl `t165_2`: u32
	// decl `t165_3`: u32
	// decl `t165_4`: u32
	// decl `t165_5`: u32
	// decl `t165_6`: u32
	// decl `t165_7`: u32
	// decl `t165_8`: u32
	// memsave `t152_0`
	// memsave `t152_1`
	// memsave `t152_2`
	// memsave `t152_3`
	// memsave `t152_4`
	// memsave `t152_5`
	// memsave `t152_6`
	// memsave `t152_7`
	// memsave `t152_8`
	// memsave `t154_0`
	// memsave `t154_1`
	// memsave `t154_2`
	// memsave `t154_3`
	// memsave `t154_4`
	// memsave `t154_5`
	// memsave `t154_6`
	// memsave `t154_7`
	// memsave `t154_8`
	// memsave `t160_0`
	// memsave `t160_1`
	// memsave `t160_2`
	// memsave `t160_3`
	// memsave `t160_4`
	// memsave `t160_5`
	// memsave `t160_6`
	// memsave `t160_7`
	// memsave `t160_8`
	// memsave `t165_0`
	// memsave `t165_1`
	// memsave `t165_2`
	// memsave `t165_3`
	// memsave `t165_4`
	// memsave `t165_5`
	// memsave `t165_6`
	// memsave `t165_7`
	// memsave `t165_8`
	// assign r6 = `t165_0`
	ld r6, r0, #0, #0				// expr `ld t165_0, self, 0, 0`
	// assign r7 = `t165_1`
	ld.e r7, r0, #32, #0				// expr `ld t165_1, self, 32, 0`
	// assign r8 = `t165_2`
	ld.e r8, r0, #64, #0				// expr `ld t165_2, self, 64, 0`
	// assign r9 = `t165_3`
	ld.e r9, r0, #96, #0				// expr `ld t165_3, self, 96, 0`
	// assign r10 = `t165_4`
	ld.e r10, r0, #128, #0				// expr `ld t165_4, self, 128, 0`
	// assign r11 = `t165_5`
	ld.e r11, r0, #160, #0				// expr `ld t165_5, self, 160, 0`
	// assign r12 = `t165_6`
	ld.e r12, r0, #192, #0				// expr `ld t165_6, self, 192, 0`
	// assign r13 = `t165_7`
	ld.e r13, r0, #224, #0				// expr `ld t165_7, self, 224, 0`
	// assign r14 = `t165_8`
	ld.e r14, r0, #256, #0				// expr `ld t165_8, self, 256, 0`
	// decl `t166_0`: u32
	// decl `t166_1`: u32
	// assign r15 = `t166_0`
	bsf r15, r10, #0, #0				// expr `bsf t166_0, t165_4, 0, 0`
	// assign r16 = `t166_1`
	bsf r16, r11, #0, #0				// expr `bsf t166_1, t165_5, 0, 0`
	// undecl `t165_0`
	// undecl `t165_1`
	// undecl `t165_2`
	// undecl `t165_3`
	// undecl `t165_4`
	// undecl `t165_5`
	// undecl `t165_6`
	// undecl `t165_7`
	// undecl `t165_8`
	// decl `t167`: u32
	// assign r6 = `t167`
	bsf r6, r15, #0, #0				// expr `bsf t167, t166_0, 0, 0`
	// undecl `t166_0`
	// undecl `t166_1`
	eq r3, r6				// expr `eq col, t167`
	// undecl `t167`
	c.jmp L158:				// expr `c.jmp L158:`

// expecting `r0` = `self`
// expecting `r1` = `char`
// expecting `r2` = `row`
// expecting `r3` = `col`
// expecting `r4` = `fore`
// expecting `r5` = `back`
// stack is [`self`, `char`, `row`, `col`, `fore`, `back`]
// from L159:
_L168:
	// undecl `self`
	// prepare state for L157:
	jmp L157:				// expr `jmp L157:`

// expecting `r0` = `self`
// expecting `r1` = `char`
// expecting `r2` = `row`
// expecting `r3` = `col`
// expecting `r4` = `fore`
// expecting `r5` = `back`
// stack is [`self`, `char`, `row`, `col`, `fore`, `back`]
// from L159:
L158:
	// decl `t170_0`: u32
	// decl `t170_1`: u32
	// decl `t170_2`: u32
	// decl `t170_3`: u32
	// decl `t170_4`: u32
	// decl `t170_5`: u32
	// decl `t170_6`: u32
	// decl `t170_7`: u32
	// decl `t170_8`: u32
	// memsave `t152_0`
	// memsave `t152_1`
	// memsave `t152_2`
	// memsave `t152_3`
	// memsave `t152_4`
	// memsave `t152_5`
	// memsave `t152_6`
	// memsave `t152_7`
	// memsave `t152_8`
	// memsave `t154_0`
	// memsave `t154_1`
	// memsave `t154_2`
	// memsave `t154_3`
	// memsave `t154_4`
	// memsave `t154_5`
	// memsave `t154_6`
	// memsave `t154_7`
	// memsave `t154_8`
	// memsave `t160_0`
	// memsave `t160_1`
	// memsave `t160_2`
	// memsave `t160_3`
	// memsave `t160_4`
	// memsave `t160_5`
	// memsave `t160_6`
	// memsave `t160_7`
	// memsave `t160_8`
	// memsave `t165_0`
	// memsave `t165_1`
	// memsave `t165_2`
	// memsave `t165_3`
	// memsave `t165_4`
	// memsave `t165_5`
	// memsave `t165_6`
	// memsave `t165_7`
	// memsave `t165_8`
	// memsave `t170_0`
	// memsave `t170_1`
	// memsave `t170_2`
	// memsave `t170_3`
	// memsave `t170_4`
	// memsave `t170_5`
	// memsave `t170_6`
	// memsave `t170_7`
	// memsave `t170_8`
	// assign r6 = `t170_0`
	ld r6, r0, #0, #0				// expr `ld t170_0, self, 0, 0`
	// assign r7 = `t170_1`
	ld.e r7, r0, #32, #0				// expr `ld t170_1, self, 32, 0`
	// assign r8 = `t170_2`
	ld.e r8, r0, #64, #0				// expr `ld t170_2, self, 64, 0`
	// assign r9 = `t170_3`
	ld.e r9, r0, #96, #0				// expr `ld t170_3, self, 96, 0`
	// assign r10 = `t170_4`
	ld.e r10, r0, #128, #0				// expr `ld t170_4, self, 128, 0`
	// assign r11 = `t170_5`
	ld.e r11, r0, #160, #0				// expr `ld t170_5, self, 160, 0`
	// assign r12 = `t170_6`
	ld.e r12, r0, #192, #0				// expr `ld t170_6, self, 192, 0`
	// assign r13 = `t170_7`
	ld.e r13, r0, #224, #0				// expr `ld t170_7, self, 224, 0`
	// assign r14 = `t170_8`
	ld.e r14, r0, #256, #0				// expr `ld t170_8, self, 256, 0`
	// undecl `self`
	// decl `t171`: u8
	// assign r0 = `t171`
	bsf r0, r12, #0, #8				// expr `bsf t171, t170_6, 0, 8`
	// undecl `t170_0`
	// undecl `t170_1`
	// undecl `t170_2`
	// undecl `t170_3`
	// undecl `t170_4`
	// undecl `t170_5`
	// undecl `t170_6`
	// undecl `t170_7`
	// undecl `t170_8`
	// decl `t172`: u1
	// memsave `t172`
	// assign r6 = `t172`
	bsf r6, r0, #5, #1				// expr `bsf t172, t171, 5, 1`
	// undecl `t171`
	eq r6, #1				// expr `eq t172, 1`
	// undecl `t172`
	c.jmp L156:				// expr `c.jmp L156:`

// expecting `r1` = `char`
// expecting `r2` = `row`
// expecting `r3` = `col`
// expecting `r4` = `fore`
// expecting `r5` = `back`
// stack is [empty, `char`, `row`, `col`, `fore`, `back`]
// from L158:
_L173:
	// prepare state for L157:
	jmp L157:				// expr `jmp L157:`

// expecting `r1` = `char`
// expecting `r2` = `row`
// expecting `r3` = `col`
// expecting `r4` = `fore`
// expecting `r5` = `back`
// stack is [empty, `char`, `row`, `col`, `fore`, `back`]
// from L158:
L156:
	// decl `u_tmp`: u32
	// assign r0 = `u_tmp`
	mov r0, r4				// expr `mov u_tmp, fore`
	mov r4, r5				// expr `mov fore, back`
	mov r5, r0				// expr `mov back, u_tmp`
	// undecl `u_tmp`
	// prepare state for L157:

// expecting `r1` = `char`
// expecting `r2` = `row`
// expecting `r3` = `col`
// expecting `r4` = `fore`
// expecting `r5` = `back`
// stack is [empty, `char`, `row`, `col`, `fore`, `back`]
// from _L163:
L157:
	mov r0, r1				// assign r0 = `char`	// expr `argst 0, char`
	// undecl `char`
	mov r1, r2				// assign r1 = `row`	// expr `argst 1, row`
	// undecl `row`
	mov r2, r3				// assign r2 = `col`	// expr `argst 2, col`
	// undecl `col`
	mov r3, #0				// expr `argst 3, 0`
	// expr `argst 4, fore`
	// undecl `fore`
	// expr `argst 5, back`
	// undecl `back`
	add.e r31, r31, #1216
	call _WriteCharFlaggedColored__:
	sub.e r31, r31, #1216				// expr `call WriteCharFlaggedColored`

//
// u_RenderState____RecalcHeaders
// args: self
//

//
// WriteCharFlaggedColored
// args: char, row, col, flags, foreColor, backColor
//

// stack is []
// from L157:
_WriteCharFlaggedColored__:
	// expr `argld char, 0`
	// expr `argld row, 1`
	// expr `argld col, 2`
	// expr `argld flags, 3`
	// expr `argld foreColor, 4`
	// expr `argld backColor, 5`
	// decl `t188`: u32
	// assign r6 = `t188`
	bsl r6, r1, #5				// expr `bsl t188, row, 5`
	// undecl `row`
	// decl `t189`: u32
	// assign r1 = `t189`
	add r1, r6, r2				// expr `add t189, t188, col`
	// undecl `t188`
	// undecl `col`
	// decl `pos`: u32
	// assign r2 = `pos`
	mov r2, r1				// expr `mov pos, t189`
	// undecl `t189`
	// decl `t190`: u8
	// assign r1 = `t190`
	bsl r1, r3, #7				// expr `bsl t190, flags, 7`
	// undecl `flags`
	// decl `t191`: u8
	// assign r3 = `t191`
	add r3, r1, r0				// expr `add t191, t190, char`
	// undecl `t190`
	// undecl `char`
	// decl `rd`: u8
	// assign r0 = `rd`
	mov r0, r3				// expr `mov rd, t191`
	// undecl `t191`
	// decl `t192`: u32
	// assign r1 = `t192`
	mov r1, r4				// expr `mov t192, foreColor`
	// undecl `foreColor`
	// decl `t193`: u32
	// assign r3 = `t193`
	mov r3, r5				// expr `mov t193, backColor`
	// undecl `backColor`
	stchr r0, r2, r1, r3				// expr `stchr rd, pos, t192, t193`
	// undecl `t193`
	// undecl `t192`
	// undecl `rd`
	// undecl `pos`

    