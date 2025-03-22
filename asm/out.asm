.DATA
	s0: "Hello world?"

.CODE
	mov.e r31, #2336			// Setup stack pointer

//
// Main
// args: 
//

// stack is []
// from :
_Main__:
	// decl `msg`: u32
	// assign r0 = `msg`
	mov.e r0, s0:				// expr `mov msg, s0:`
	// decl `x`: u32
	// assign r1 = `x`
	mov r1, #17				// expr `mov x, 17`
	// decl `ptr`: u32
	// assign r2 = `ptr`
	add.e r29, r31, #32
	mov r2, r29				// expr `mov ptr, x.&`
	// decl `t3`: u32
	// assign r3 = `t3`
	mov r3, #16				// expr `mov t3, 16`
	stw r3, r2, #0				// expr `stw t3, ptr, 0`
	// undecl `t3`
	sub r1, r1, #5				// expr `sub x, x, 5`
	// expr `argst 0, msg`
	stw.e r1, r31, #32
	mov r1, #0				// expr `argst 1, 0`
	stw.e r2, r31, #64
	mov.e r2, #16777215				// expr `argst 2, 16777215`
	mov r3, #0				// expr `argst 3, 0`
	ldw.e r4, r31, #64				// assign r4 = `ptr`	// expr `argst 4, ptr`
	stw r0, r31, #0
	stw.e r4, r31, #64
	add.e r31, r31, #128
	call _PrintStr__:
	sub.e r31, r31, #128				// expr `call PrintStr`
	// expr `retld t4, 0`
	// decl `t5`: u32
	// assign r1 = `t5`
	ldw.e r2, r31, #32				// assign r2 = `x`
	add r1, r2, #2				// expr `add t5, x, 2`
	add.e r29, r31, #32
	stw r1, r29, #0				// expr `stw t5, x.&, 0`
	// undecl `t5`
	// undecl `x`
	stw.e r0, r31, #96				// clobbering r0 (`t4`)
	ldw r0, r31, #0				// assign r0 = `msg`	// expr `argst 0, msg`
	// undecl `msg`
	mov r1, #0				// expr `argst 1, 0`
	mov r2, #0				// expr `argst 2, 0`
	mov.e r3, #16777215				// expr `argst 3, 16777215`
	ldw.e r4, r31, #64				// assign r4 = `ptr`	// expr `argst 4, ptr`
	// undecl `ptr`
	add.e r31, r31, #192
	call _PrintStr__:
	sub.e r31, r31, #192				// expr `call PrintStr`
	// expr `retld t6, 0`

// expecting `r0` = `t6`
// stack is [`t6`, empty, empty, `t4`]
// from _Main__:
L7:
	jmp L8:				// expr `jmp L8:`

// expecting `r0` = `t6`
// stack is [`t6`, empty, empty, `t4`]
// from L7:
L8:
	// prepare state for L7:
	jmp L7:				// expr `jmp L7:`

//
// PrintStr
// args: charPtr_0, rendFlags_0, foreGround_0, backGround_0, pos_0
//

// stack is []
// from _Main__:
_PrintStr__:
	// expr `argld charPtr, 0`
	// expr `argld rendFlags, 1`
	// expr `argld foreGround, 2`
	// expr `argld backGround, 3`
	// expr `argld pos, 4`
	// decl `t15`: u8
	// assign r5 = `t15`
	ldw r5, r0, #0				// expr `ldw t15, charPtr, 0`
	// decl `char`: u8
	// assign r6 = `char`
	mov r6, r5				// expr `mov char, t15`
	// undecl `t15`

// expecting `r0` = `charPtr`
// expecting `r1` = `rendFlags`
// expecting `r2` = `foreGround`
// expecting `r3` = `backGround`
// expecting `r4` = `pos`
// expecting `r6` = `char`
// stack is [`charPtr`, `rendFlags`, `foreGround`, `backGround`, `pos`, `char`]
// from _PrintStr__:
L12:
	ne r6, #0				// expr `ne char, 0`
	c.jmp L13:				// expr `c.jmp L13:`

// expecting `r0` = `charPtr`
// expecting `r1` = `rendFlags`
// expecting `r2` = `foreGround`
// expecting `r3` = `backGround`
// expecting `r4` = `pos`
// expecting `r6` = `char`
// stack is [`charPtr`, `rendFlags`, `foreGround`, `backGround`, `pos`, `char`]
// from L12:
_L16:
	// undecl `charPtr`
	// undecl `backGround`
	// undecl `foreGround`
	// undecl `pos`
	// undecl `rendFlags`
	// undecl `char`
	jmp L14:				// expr `jmp L14:`

// expecting `r0` = `charPtr`
// expecting `r1` = `rendFlags`
// expecting `r2` = `foreGround`
// expecting `r3` = `backGround`
// expecting `r4` = `pos`
// expecting `r6` = `char`
// stack is [`charPtr`, `rendFlags`, `foreGround`, `backGround`, `pos`, `char`]
// from L12:
L13:
	// decl `t18`: u32
	// assign r5 = `t18`
	bsl r5, r1, #8				// expr `bsl t18, rendFlags, 8`
	// decl `t19`: u32
	// assign r7 = `t19`
	add r7, r6, r5				// expr `add t19, char, t18`
	// undecl `t18`
	// decl `flagChar`: u32
	// assign r5 = `flagChar`
	mov r5, r7				// expr `mov flagChar, t19`
	// undecl `t19`
	// decl `t20`: u32
	// assign r7 = `t20`
	ldw r7, r4, #0				// expr `ldw t20, pos, 0`
	stchr r5, r7, r2, r3				// expr `stchr flagChar, t20, foreGround, backGround`
	// undecl `t20`
	// undecl `flagChar`
	// decl `t21`: u32
	// assign r5 = `t21`
	ldw r5, r4, #0				// expr `ldw t21, pos, 0`
	// decl `t22`: u32
	// assign r7 = `t22`
	add r7, r5, #1				// expr `add t22, t21, 1`
	// undecl `t21`
	stw r7, r4, #0				// expr `stw t22, pos, 0`
	// undecl `t22`
	add r0, r0, #1				// expr `add charPtr, charPtr, 1`
	// decl `t23`: u8
	// assign r5 = `t23`
	ldw r5, r0, #0				// expr `ldw t23, charPtr, 0`
	mov r6, r5				// expr `mov char, t23`
	// undecl `t23`
	// prepare state for L12:
	jmp L12:				// expr `jmp L12:`

// stack is []
// from _L16:
L14:
	ret 				// expr `ret`

    