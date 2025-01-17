  jmp Main:
  nop

.DATA
str: "Hello world!" [8x'0]

.CODE
Main:
  mov	R0, #17
  mov 	R31, #1
  mov.e	R30, str:
  stw	R31, R30, #0