  jmp    Main:


//Place value into r0, allow r31 to be a junk reg, returns via r0
Dab:
  vsub   r31, r0,  #5,         #4       		//Subtract from each nibble the number 5 into r1
  bit.e  r31, r31, #0x8888888, %BIT(a & b ^ b)  	//r1 = r1 & 0x8... ^ 0x8...  //Highest bit in the nibble contains if it was greater than 4
  bsr    r31, r31, #3                			//r1 >>= 3 //Now lowest bit holds it
  adds   r31, r31, r31,        #1            		//r1 = r1 + r1 << 1 //a fast multiplication by 3 on all bits, so 3 if was greater else 0
  vadd   r0,  r0,  r31,        #4            		//This can also just be add, it never overflows the nibble
  ret


Main:
  mov.e  r8,  #107
  mov    r9,  #0	//Accumulator

Loop:
  eq     r8,  #0
  c.jmp  End:

	//Dabble
  mov    r0,  r8        //Move r8 for call
  call   Dab:
  mov    r8,  r0        //Move ret back to r0
	//Double
  bsl.s  r8,  r8,  #1   //Store overflow bit in carry
  bsl    r9,  r9,  #1   //Shift over accum
  radd   r9,  r9,  #0   //Add overflow bit to lsb  

  jmp    Loop:

End:
  mov.e  r1,  #0x107    //It should equal this now
  mov    r0,  r9
  susp