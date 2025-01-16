  jmp Main:
  nop

.DATA
str: "Hello world!" [8x'0]

.CODE
Main:
  mov	R0, #17
  mov 	R1F, #1
  mov.e	R1E, str:
  stw	R1F, R1E, #0