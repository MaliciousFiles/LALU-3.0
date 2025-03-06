	mov.e r31, #2752
_Main__:
	// decl `x`: u32
	// decl `place`: u32
	// assign r0 = `place`
	mov r0, #1				// expr `mov place, 1`
L3:
	// decl `chr`: u32
	// assign r1 = `chr`
	ult.e r1, #54				// expr `ult chr, 54`
	c.jmp L5:				// expr `c.jmp L5:`
_L8:
	jmp L7:				// expr `jmp L7:`
L5:
	jmp L2:				// expr `jmp L2:`
L7:
	ugt.e r1, #63				// expr `ugt chr, 63`
	c.jmp L5:				// expr `c.jmp L5:`
_L10:
	jmp L6:				// expr `jmp L6:`
L2:
	// decl `t20`: u32
	// assign r2 = `t20`
	ldkey r2				// expr `ldkey t20`
	mov r1, r2				// expr `mov chr, t20`
	// undecl `t20`
	ne.e r1, #51				// expr `ne chr, 51`
	c.stw.e r1, r31, #2048
	c.jmp L3:				// expr `c.jmp L3:`
_L21:
	// undecl `place`
	// undecl `chr`
	jmp L4:				// expr `jmp L4:`
L6:
	// decl `t13`: u32
	// assign r2 = `t13`
	sub.e r2, r1, #53				// expr `sub t13, chr, 53`
	// decl `temp`: u32
	// assign r3 = `temp`
	mov r3, r2				// expr `mov temp, t13`
	// undecl `t13`
	eq r3, #10				// expr `eq temp, 10`
	c.jmp L14:				// expr `c.jmp L14:`
_L16:
	jmp L15:				// expr `jmp L15:`
L4:
	// assign r0 = `x`
	// expr `argst 0, x`
	// undecl `x`
	add.e r31, r31, #128
	call _Fac__:
	sub.e r31, r31, #128				// expr `call Fac`
	// decl `t23`: u32
	// expr `retld t23, 0`
	// decl `fac`: u32
	// assign r1 = `fac`
	mov r1, r0				// expr `mov fac, t23`
	// undecl `t23`
	mov r0, r1				// assign r0 = `fac`	// expr `argst 0, fac`
	// undecl `fac`
	add.e r31, r31, #224
	call _BCD__:
	sub.e r31, r31, #224				// expr `call BCD`
	// decl `t24`: u32
	// expr `retld t24, 0`
	// decl `bcd`: u32
	// assign r1 = `bcd`
	mov r1, r0				// expr `mov bcd, t24`
	// undecl `t24`
	// decl `idx`: u32
	// assign r0 = `idx`
	mov r0, #0				// expr `mov idx, 0`
L27:
	// decl `t29`: u32
	// assign r2 = `t29`
	and r2, r1, #15				// expr `and t29, bcd, 15`
	// decl `t30`: u32
	// assign r3 = `t30`
	add.e r3, r2, #48				// expr `add t30, t29, 48`
	// undecl `t29`
	stchr.e r3, r0, #4294967295, #0				// expr `stchr t30, idx, 4294967295, 0`
	// undecl `t30`
	add r0, r0, #1				// expr `add idx, idx, 1`
	// undecl `idx`
	mov r1, #4				// expr `mov bcd, 4`
L26:
	ne r1, #0				// expr `ne bcd, 0`
	// undecl `bcd`
	c.jmp L28:				// expr `c.jmp L28:`
_L32:
L14:
	mov r3, #0				// expr `mov temp, 0`
L15:
	// decl `t19`: u32
	// assign r2 = `t19`
	mul r2, r3, r0				// expr `mul t19, temp, place`
	// undecl `temp`
	// assign r3 = `x`
	add r3, r3, r2				// expr `add x, x, t19`
	// undecl `t19`
	mul r0, r0, #10				// expr `mul place, place, 10`
_Fac__:
	// expr `argld n, 0`
	eq r0, #1				// expr `eq n, 1`
	c.jmp L34:				// expr `c.jmp L34:`
_L36:
	jmp L35:				// expr `jmp L35:`
_BCD__:
	// expr `argld x, 0`
	// decl `y`: u32
	// assign r1 = `y`
	mov r1, #0				// expr `mov y, 0`
L44:
	ne r0, #0				// expr `ne x, 0`
	c.jmp L46:				// expr `c.jmp L46:`
_L47:
L45:
	// decl `t48`: u32
	// assign r2 = `t48`
	dab r2, r1				// expr `dab t48, y`
	mov r1, r2				// expr `mov y, t48`
	// undecl `t48`
	mov r1, #1				// expr `mov y, 1`
	// decl `t53`: u32
	// assign r2 = `t53`
	and.e r2, r0, #2147483648				// expr `and t53, x, 2147483648`
	ne r2, #0				// expr `ne t53, 0`
	// undecl `t53`
	c.jmp L51:				// expr `c.jmp L51:`
_L54:
L50:
	or r1, r1, #1				// expr `or y, y, 1`
L28:
	susp 				// expr `susp `
L34:
	// undecl `n`
	mov r0, #1				// expr `retst 0, 1`
	ret 				// expr `ret `
L35:
	// decl `t39`: u32
	// assign r1 = `t39`
	sub r1, r0, #1				// expr `sub t39, n, 1`
	stw r0, r31, #0				// clobbering r0 (`n`)
	mov r0, r1				// assign r0 = `t39`	// expr `argst 0, t39`
	// undecl `t39`
	add.e r31, r31, #64
	call _Fac__:
	sub.e r31, r31, #64				// expr `call Fac`
	// decl `t40`: u32
	// expr `retld t40, 0`
	// decl `t41`: u32
	// assign r1 = `t41`
	ldw r2, r31, #0				// assign r2 = `n`
	mul r1, r2, r0				// expr `mul t41, n, t40`
	// undecl `t40`
	// undecl `n`
	mov r0, r1				// assign r0 = `t41`	// expr `retst 0, t41`
	// undecl `t41`
	ret 				// expr `ret `
L46:
	// undecl `x`
	mov r0, r1				// assign r0 = `y`	// expr `retst 0, y`
	// undecl `y`
	ret 				// expr `ret `
L51:
	mov r0, #1				// expr `mov x, 1`
	jmp L44:				// expr `jmp L44:`