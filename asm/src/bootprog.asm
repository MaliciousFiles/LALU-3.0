jmp  Main:

%EXPORT Boot:

Main:
  mov  r0,  #2342
  mov  r1,  #17

  gcld r30		//r30 = then = Time.Now()
  call DivMod:
  gcld r29		//r29 = now = Time.Now()

  eq  r0, 137		//Expect r0 = 137
    cn.jmp  Error:
  eq  r1, 14		//Expect r1 = 14
    cn.jmp  Error:

  sub  r29, r29, r30    //r29 = delta = now - then

  susp
Error:
  mov  r31, #0xBAD
  susp
  

//::LLPC-COMPAT
//::ANNOT[u32* u32* u32* -> u32]
//fn DivMod(r0 = progPtr, r1 = roPtr, r2 = rwPtr) 0
Boot:
  sub  r2,  r0,  #1		//r2 = npow
  log  r2,  r2
  add  r2,  r2,  #1		//npow = log(a - 1) + 1

  bsl  r3,  #1,  r2		//r3 = 1 << npow
  sub  r4,  r3,  r1		//r4 = diff = (1<<npow) - b
  sub  r3,  r3,  #1		//r3 = mask = (1<<npow) - 1
  
  mov  r7,  #0			//r7 = r = 0

  loop:				//while (True) {
    and    r5,  r0,  r3		//  r5 = c = a & mask
    bsl.s  r6,  r0,  r2         //  r6 = d = a >> npow
    zf
    cn.jmp  skip:		//  if (d == 0) {
      csub  r5,  r5,  r1        //    if (c > b) c -= b 
      mov   r0,  r7		//    ret{0} = r
      mov   r1,  r5		//    ret{1} = c
      ret 			//    return
    skip:			//  }
    add     r7,  r7,  r6        //  r += d
    mul     r0,  r6,  r4	//  a = d * diff 
				//   // = (d_0 * diff_0)  
    ulmul   r8,  r7,  r6	//   // r8 = temp
    adds    r0,  r0,  r8,  #16	//   // + (d_1 * diff_0)<<16
    lumul   r8,  r7,  r6	
    adds    r0,  r0,  r8,  #16	//   // + (d_0 + diff_1)<<16 
    add     r0,  r0,  r5	//  a += c			 
  jmp     loop:			//}