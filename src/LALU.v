// Formats
`define TRIP		        2'b00
`define WB_TRIP		        3'b000
`define NO_WB_TRIP		    3'b100

`define QUAD		        2'b01
`define WB_QUAD		        3'b001
`define NO_WB_QUAD		    3'b101

`define JMP		            3'b110

// Functions
`define ADD		            9'b0_0000_0001
`define SUB		            9'b0_0000_0010
`define RADD		        9'b0_0000_1101
`define RSUB		        9'b0_0000_1110
`define ADDS                4'b1000
`define ADDRS               4'b1001
`define CSUB		        9'b0_0010_0000
`define MUL		            9'b0_0000_0011
`define UUMUL				9'b0_0000_1010
`define ULMUL				9'b0_0000_1011
`define LUMUL				9'b0_0000_1100
`define ABS				    9'b0_0001_0000
`define BSL		            9'b0_0000_0100
`define BSR		            9'b0_0000_0101
`define BRL		            9'b0_0000_0110
`define BRR		            9'b0_0000_0111
`define UMAX				9'b0_0001_0001
`define UMIN				9'b0_0001_0010
`define SMAX				9'b0_0001_0011
`define SMIN				9'b0_0001_0100
`define ANY		            9'b0_0000_1000
`define LOG				    9'b0_0001_0101
`define CTZ				    9'b0_0001_0110
`define PCNT				9'b0_0001_0111
`define BRVS				9'b0_0001_1000
`define SRVS				9'b0_0001_1111
`define VANY				9'b0_0001_1001
`define VADD				4'b0110
`define VSUB				4'b0111
`define BEXT				9'b0_0001_1100
`define BDEP				9'b0_0001_1101
`define EXS				    9'b0_0001_1110
`define LSB				    9'b0_0000_1111
`define HSB		            9'b0_0000_1001

`define BIT		            9'b0000

`define LD		            4'b0010
`define ST		            4'b0011
`define BSF		            4'b0100
`define BST		            4'b0101

`define RET		            9'b0_0010_0011
`define CALL		        2'b00
`define JUMP		        2'b01

`define STCHR               4'b0000
`define LDKEY               9'b0_0011_0001
`define KEYPR               9'b0_0011_0010
`define RSTKEY              9'b0_0011_0011

`define UGT		            9'b0_1000_0000
`define UGE		            9'b0_1000_0001
`define ULT		            9'b0_1000_0010
`define ULE		            9'b0_1000_0011
`define SGT		            9'b0_1000_0100
`define SGE		            9'b0_1000_0101
`define SLT		            9'b0_1000_0110
`define SLE		            9'b0_1000_0111
`define EQ		            9'b0_1000_1000
`define NE		            9'b0_1000_1001

// all flag get func IDs start with this, used to identify a need to stall later
`define FLAG_GET_INSTR		6'b0_1001_0
`define NF		            9'b0_1001_0000
`define ZF		            9'b0_1001_0001
`define CF		            9'b0_1001_0010
`define OF		            9'b0_1001_0011
`define NNF		            9'b0_1001_0100
`define NZF		            9'b0_1001_0101
`define NCF		            9'b0_1001_0110
`define NOF		            9'b0_1001_0111

`define GCLD				9'b1_1111_1111
`define SUSP				9'b1_1111_1111

module LALU(input CLOCK_50,
    input PS2_CLK, input PS2_DAT,
    output [7:0] VGA_R, VGA_G, VGA_B,
    output VGA_CLK, VGA_SYNC_N, VGA_BLANK_N, VGA_HS, VGA_VS,
    output wire suspended);
    /*********************
     *      Memory       *
     *********************/
    wire [15:0] fetchAddress;
    wire [31:0] fetchOutput;

    wire [15:0] memAccessAddress;
    wire memAccessWren;
    wire [31:0] memAccessInput;
    wire memAccessRden;
    wire [31:0] memAccessOutput;
    operational_memory MEM(
        .clk(CLOCK_50),
        .operationMode(operationMode),

        .fetchAddress(fetchAddress),
        .fetchEnable(~stall_e),
        .fetchOutput(fetchOutput),

        .memAccessAddress(memAccessAddress),
        .memAccessWren(memAccessWren),
        .memAccessData(memAccessInput),
        .memAccessRden(memAccessRden),
        .memAccessOutput(memAccessOutput));


    wire [11:0] stackReadAddr, stackWriteAddr;
    wire [16:0] stackReadOut, stackWriteData;
    wire stackWren;
    RAM #(12, 17) STACK(
        .clk(CLOCK_50),

        .address_a(stackReadAddr),
        .q_a(stackReadOut),
        .rden_a(1'b1),
        .data_a(17'b0),
        .wren_a(1'b0),

        .address_b(stackWriteAddr),
        .wren_b(stackWren),
        .data_b(stackWriteData),
        .rden_b(1'b0),
        .q_b());


    /*********************
     *    Peripherals    *
     *********************/
    wire rstKeyboard;
    wire pollKeyboard;
    wire [17:0] keyboardOut;
    Keyboard keyboard (
        .CLOCK_50(CLOCK_50),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),

        .reset(rstKeyboard),
        .poll(pollKeyboard),
        .out(keyboardOut));

    wire charWr;
    wire [23:0] charWrFgColor;
    wire [23:0] charWrBgColor;
    wire [7:0] charWrCode;
    wire [5:0] charWrX;
    wire [4:0] charWrY;
    VGA vga (
        .CLOCK_50(CLOCK_50),

        .charWr(charWr),
        .charWrFgColor(charWrFgColor),
        .charWrBgColor(charWrBgColor),
        .charWrCode(charWrCode),
        .charWrX(charWrX),
        .charWrY(charWrY),

        .VGA_CLK(VGA_CLK),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B));

    /*********************
     *     Registers     *
     *********************/
    // GENERAL
    integer globalCounter = 0; // how many cycles the processor has been running for
    always @(posedge CLOCK_50) if (run) globalCounter <= globalCounter + 1;

    reg [15:0] IP = 0; // instruction pointer
    reg operationMode = 1; // 0 = user mode, 1 = kernel mode
    reg run = 1; // setting to 0 entirely stops the processor
    assign suspended = ~run;

    reg [11:0] stackPointer = 0;

    // TODO: for debug only
    wire [31:0] reg0 = registers[0];
    wire [31:0] reg1 = registers[1];
    wire [31:0] reg2 = registers[2];
    wire [31:0] reg3 = registers[3];
    wire [31:0] reg4 = registers[4];
    wire [31:0] reg5 = registers[5];
    wire [31:0] reg6 = registers[6];
    wire [31:0] reg7 = registers[7];
    wire [31:0] reg8 = registers[8];
    wire [31:0] reg9 = registers[9];
    wire [31:0] reg10 = registers[10];
    wire [31:0] reg11 = registers[11];
    wire [31:0] reg12 = registers[12];
    wire [31:0] reg13 = registers[13];
    wire [31:0] reg14 = registers[14];
    wire [31:0] reg15 = registers[15];
    wire [31:0] reg16 = registers[16];
    wire [31:0] reg17 = registers[17];
    wire [31:0] reg18 = registers[18];
    wire [31:0] reg19 = registers[19];
    wire [31:0] reg20 = registers[20];
    wire [31:0] reg21 = registers[21];
    wire [31:0] reg22 = registers[22];
    wire [31:0] reg23 = registers[23];
    wire [31:0] reg24 = registers[24];
    wire [31:0] reg25 = registers[25];
    wire [31:0] reg26 = registers[26];
    wire [31:0] reg27 = registers[27];
    wire [31:0] reg28 = registers[28];
    wire [31:0] reg29 = registers[29];
    wire [31:0] reg30 = registers[30];
    wire [31:0] reg31 = registers[31];

    reg [31:0] registers[0:31]; // registers
    integer i, j;
    initial for (i = 0; i < 32; i = i + 1) registers[i] = 31'b0;

    reg generalFlag = 0;
    reg negativeFlag = 0;
    reg overflowFlag = 0;
    reg carryFlag = 0;
    reg zeroFlag = 0;

    // FETCH
    reg [15:0] IP_f = 0; // instruction pointer at fetch stage
    reg isValid_f_reg = 0; // whether the fetched instruction is valid

    // DECODE
    reg [15:0] IP_d = 0; // instruction pointer at decode stage
    reg isValid_d = 0; // whether the decoded instruction is valid
    reg [2:0] exImm = 0; // whether the next instruction is an extended immediate
    reg updateEIP = 0; // used for updating expected IP
    reg [4:0] Rd_d = 0; // destination register at decode stage
    reg [4:0] Rs0_d = 0; // source register at decode stage
    reg i0 = 0; // whether the source register is an immediate
    reg [4:0] Rs1_d = 0;
    reg i1 = 0;
    reg [4:0] Rs2_d = 0;
    reg i2 = 0;
    reg [20:0] jumpLoc = 0; // jump loc (doesn't nop if not jump, as execute only uses if jump)
    reg [2:0] jumpPageLoc = 0;
    reg sticky_d = 0; // sticky flag at decode stage
    reg conditional = 0; // conditional flag
    reg negate = 0; // conditional negation flag
    reg [2:0] format = 0; // which format the instruction is in
    reg [8:0] funcID = 0; // which operation within the format (variable number of bits; 9 max)
    reg isWriteback_d = 0; // whether the instruction writes back to a register

    // EXECUTE
    reg [15:0] IP_e = 0; // instruction pointer at execute stage
    reg isValid_e_reg = 0; // whether the executed instruction is valid
    reg invalidFunction = 0; // if the FMT/FuncID pairing wasn't recognized
    reg [15:0] expectedIP = 0; // expected instruction pointer; if incorrect, is synced with IP

    reg [4:0] Rd_e = 0;
    reg sticky_e = 0;
    reg isWriteback_e = 0;
    reg isMemRead_e = 0;
    reg isMemWrite_e = 0;

    reg [31:0] result_e = 0;
    reg carryFlag_e = 0;
    reg overflowFlag_e = 0;

    reg [15:0] memAccessAddress_e = 0;
    reg [4:0] memAccessNumBitsBefore_e = 0;
    reg [4:0] memAccessNumBits_e = 0;
    reg [4:0] memAccessNumBitsAfter_e = 0;

    reg [16:0] returnAddress;
    reg isRet_e = 0;

    reg halt_e = 0;

    // MEMORY READ
    reg [15:0] IP_m = 0; // instruction pointer at memory read stage
    reg isValid_m = 0; // whether the memory read instruction is valid

    reg sticky_m = 0;
    reg isWriteback_m = 0;
    reg isMemRead_m = 0;
    reg isMemWrite_m = 0;

    reg [4:0] Rd_m = 0;
    reg carryFlag_m = 0;
    reg overflowFlag_m = 0;
    reg [31:0] result_m = 0;

    reg [15:0] memAccessAddress_m = 0;
    reg [4:0] memAccessNumBitsBefore_m = 0;
    reg [4:0] memAccessNumBits_m = 0;
    reg [4:0] memAccessNumBitsAfter_m = 0;

    reg halt_m = 0;

    // WRITEBACK
    reg memAccessWren_w = 0;
    reg [15:0] memAccessAddress_w = 0;
    reg [31:0] memAccessInput_w = 0;

    /*********************
     *       Fetch       *
     *********************/
    assign fetchAddress = IP; // fetch address is the current instruction pointer
    wire [31:0] instruction = fetchOutput; // current fetched instruction (as used in decode)
    wire isValid_f = isValid_f_reg && ~extendedImmediate; // whether the fetched instruction is valid

    always @(posedge CLOCK_50) begin if (run) if (~stall_e) begin
        IP_f <= IP; // save IP of fetched instruction

        IP <= executiveOverride
            ? expectedIP    // if execOverride, sync IP to EIP
            : IP + 1;       // else, increment IP

        isValid_f_reg <= ~executiveOverride;
    end end

    /*********************
     *       Decode      *
     *********************/
    wire [2:0] curFormat = instruction[2:0]; // current instruction format, to know how to decode
    wire extendedImmediate = exImm[0] || exImm[1] || exImm[2];
    always @(posedge CLOCK_50) if (run) updateEIP <= ~stall_e && ~executiveOverride && isValid_f_reg;
    always @(posedge CLOCK_50) begin if (run) if (~stall_e) begin if (isValid_f) begin
        IP_d <= IP_f; // save IP of decoded instruction
        isValid_d <= 1'b1;

        // Universal
        format <= curFormat;
        conditional <= instruction[31];
        negate <= instruction[30];
        sticky_d <= instruction[29];

        if (curFormat[1:0] == `TRIP) begin // triple
            Rd_d <= instruction[28:24];

            Rs0_d <= instruction[23:19];
            Rs1_d <= instruction[18:14];

            funcID <= instruction[13:5];

            i0 <= instruction[4];
            i1 <= instruction[3];

            exImm <= {
                1'b0,
                instruction[3] && instruction[18:14] == 5'b11111,
                instruction[4] && instruction[23:19] == 5'b11111};

            isWriteback_d <= ~curFormat[2];

            // unused by triple
            Rs2_d <= 5'b0;
            i2 <= 1'b0;
            jumpLoc <= 21'b0;
            jumpPageLoc <= 3'b0;
        end else if (curFormat[1:0] == `QUAD) begin // quad
            Rd_d <= instruction[28:24];

            Rs0_d <= instruction[23:19];
            Rs1_d <= instruction[18:14];
            Rs2_d <= instruction[13:9];

            funcID <= {5'b0, instruction[8:5]};

            i1 <= instruction[4];
            i2 <= instruction[3];

            exImm <= {
                instruction[3] && instruction[13:9] == 5'b11111,
                instruction[4] && instruction[18:14] == 5'b11111,
                1'b0};

            isWriteback_d <= ~curFormat[2];

            // unused by quad
            i0 <= 1'b0;
            jumpLoc <= 21'b0;
            jumpPageLoc <= 3'b0;
        end else if (curFormat == `JMP) begin // jump
            jumpPageLoc <= instruction[28:26];
            jumpLoc <= instruction[25:5];

            funcID <= {7'b0, instruction[4:3]};

            // unused by jump
            Rd_d <= 5'b0;
            Rs0_d <= 5'b0;
            Rs1_d <= 5'b0;
            Rs2_d <= 5'b0;
            i0 <= 1'b0;
            i1 <= 1'b0;
            i2 <= 1'b0;
            exImm <= 3'b0;
            isWriteback_d <= 1'b0;
        end
    end else begin exImm <= 3'b0; isValid_d <= 1'b0; end end end

    /*********************
     *      Execute      *
     *********************/
    // assign stack wires
    assign stackReadAddr = stackPointer - 2;

    assign stackWriteAddr = stackPointer;
    assign stackWren = isValid_d && format == `JMP && funcID == `CALL;
    assign stackWriteData = {operationMode, IP_d + 16'b1};


    wire stall_e = (isValid_d && isWriteback_e && isMemRead_e && ((~i0 && Rs0_d == Rd_e && format != `JMP) || (~i1 && Rs1_d == Rd_e && format != `JMP) || (~i2 && Rs2_d == Rd_e && format[1:0] == `QUAD) || (Rd_d == Rd_e && (format == `WB_QUAD && funcID == `BST))))
                || (isValid_d && sticky_e && isWriteback_e && isMemRead_e && format == `NO_WB_TRIP && funcID[8:3] == `FLAG_GET_INSTR)
                || stall_m;
    wire isValid_e = isValid_e_reg && ~invalidFunction;
    wire executiveOverride = isValid_d && expectedIP != IP_d; // whether to override IP with EIP

    wire [31:0] Rs0 = i0
        ? exImm[0] ? fetchOutput : Rs0_d
        : isValid_e && isWriteback_e && Rs0_d == Rd_e ? result_e
        : isValid_m && isWriteback_m && Rs0_d == Rd_m ? finalResult_w
        : registers[Rs0_d];
    wire [31:0] Rs1 = i1
        ? exImm[1] ? fetchOutput : Rs1_d
        : isValid_e && isWriteback_e && Rs1_d == Rd_e ? result_e
        : isValid_m && isWriteback_m && Rs1_d == Rd_m ? finalResult_w
        : registers[Rs1_d];
    wire [31:0] Rs2 = i2
        ? exImm[2] ? fetchOutput : Rs2_d
        : isValid_e && isWriteback_e && Rs2_d == Rd_e ? result_e
        : isValid_m && isWriteback_m && Rs2_d == Rd_m ? finalResult_w
        : registers[Rs2_d];
    wire [31:0] Rd = isValid_e && isWriteback_e && Rd_d == Rd_e ? result_e
        : isValid_m && isWriteback_m && Rd_d == Rd_m ? finalResult_w
        : registers[Rd_d];

    // have to bring these out since the result is used for setting CF and OF
    wire [32:0] sum  = Rs0 + Rs1, sum_carry  = Rs0 + Rs1 + CF, sum_shift = Rs0 + (Rs1 << Rs2), sum_right_shift = Rs0 + (Rs1 >> Rs2);
    wire [32:0] diff = Rs0 - Rs1, diff_carry = Rs0 - Rs1 + CF;

    // bring out flags for diff calc, since all comparisons use them
    wire diff_NF = diff[31];
    wire diff_OF = Rs0[31] != Rs1[31] && Rs0[31] != diff[31];
    wire diff_CF = diff[32];
    wire diff_ZF = diff == 0;

    // bring out flags for all flag get instructions, with passthru
    wire NF = sticky_e && isWriteback_e ? result_e[31]
        : sticky_m && isWriteback_m ? finalResult_w[31]
        : negativeFlag;
    wire OF = sticky_e && isWriteback_e ? overflowFlag_e
        : sticky_m && isWriteback_m ? overflowFlag_m
        : overflowFlag;
    wire CF = sticky_e && isWriteback_e ? carryFlag_e
          : sticky_m && isWriteback_m ? carryFlag_m
          : carryFlag;
    wire ZF = sticky_e && isWriteback_e ? result_e == 0
        : sticky_m && isWriteback_m ? finalResult_w == 0
        : zeroFlag;

    // peripherals
    assign rstKeyboard = isValid_d && format == `NO_WB_TRIP && funcID == `RSTKEY;
    assign pollKeyboard = run && ~stall_m && ~stall_e && ~executiveOverride && executeInstr && format == `WB_TRIP && funcID == `LDKEY;

    assign charWr = run && ~stall_m && ~stall_e && ~executiveOverride && executeInstr && format == `NO_WB_QUAD && funcID == `STCHR;
    assign charWrFgColor = Rs1;
    assign charWrBgColor = Rs2;
    assign charWrCode = Rd;
    assign charWrX = Rs0[5:0];
    assign charWrY = Rs0[9:6];

    wire executeInstr = isValid_d && ~(conditional && generalFlag == negate);
    always @(posedge CLOCK_50) begin if (run) if (~stall_m) begin if (~stall_e && ~executiveOverride) begin
        if (updateEIP) begin
            expectedIP <= expectedIP + 1;
        end
        if (executeInstr) begin
            IP_e <= IP_d; // save IP of executed instruction
            isValid_e_reg <= 1'b1;

            Rd_e <= Rd_d;
            sticky_e <= sticky_d;
            isWriteback_e <= isWriteback_d;

            // TODO: probably better to make these an OR than driving them multiple times :|
            invalidFunction <= 1'b0;
            isMemRead_e <= 1'b0;
            isMemWrite_e <= 1'b0;
            carryFlag_e <= 1'b0;
            overflowFlag_e <= 1'b0;
            isRet_e <= 1'b0;

            if (format == `WB_TRIP) begin
                case (funcID)
                    `ADD: begin
                        result_e <= sum[31:0];
                        carryFlag_e <= sum[32];
                        overflowFlag_e <= (Rs0[31] == Rs1[31] && Rs0[31] != sum[31]);
                    end
                    `SUB: begin
                        result_e <= diff[31:0];
                        carryFlag_e <= diff_CF;
                        overflowFlag_e <= diff_OF;
                    end
                    `RADD: begin
                        result_e <= sum_carry;
                        carryFlag_e <= sum_carry[32];
                        overflowFlag_e <= (Rs0[31] == Rs1[31] && Rs0[31] != sum_carry[31]);
                    end
                    `RSUB: begin
                        result_e <= diff_carry;
                        carryFlag_e <= diff_carry[32];
                        overflowFlag_e <= (Rs0[31] == Rs1[31] && Rs0[31] != diff_carry[31]);
                    end
                    `CSUB: begin
                        result_e <= Rs1 <= Rs0 ? diff : Rs0;
                        overflowFlag_e <= Rs1 > Rs0;
                    end
                    `MUL: begin
                        result_e <= Rs0[15:0] * Rs1[15:0];
                    end
                    `UUMUL: begin
                        result_e <= Rs0[31:16] * Rs1[31:16];
                    end
                    `ULMUL: begin
                        result_e <= Rs0[31:16] * Rs1[15:0];
                    end
                    `LUMUL: begin
                        result_e <= Rs0[15:0] * Rs1[31:16];
                    end
                    `ABS: begin
                        result_e <= Rs0[31] ? -Rs0 : Rs0;
                    end
                    `BSL: begin
                        result_e <= Rs0 << Rs1;
                        carryFlag_e <= Rs1 == 0 ? 0 : Rs0[32-Rs1];
                    end
                    `BSR: begin
                        result_e <= Rs0 >> Rs1;
                        carryFlag_e <= Rs1 == 0 ? 0 : Rs0[Rs1-1];
                    end
                    `BRL: begin
                        result_e <= Rs0 << Rs1 | Rs0 >> (32-Rs1);
                    end
                    `BRR: begin
                        result_e <= Rs0 >> Rs1 | Rs0 << (32-Rs1);
                    end
                    `UMAX: begin
                        result_e <= Rs0 > Rs1 ? Rs0 : Rs1;
                    end
                    `UMIN: begin
                        result_e <= Rs0 < Rs1 ? Rs0 : Rs1;
                    end
                    `SMAX: begin
                        result_e <= Rs0[31] == Rs1[31] == (Rs0 > Rs1) ? Rs0 : Rs1;
                    end
                    `SMIN: begin
                        result_e <= Rs0[31] == Rs1[31] == (Rs0 < Rs1) ? Rs0 : Rs1;
                    end
                    `ANY: begin
                        result_e <= Rs0 != 0;
                    end
                    `LOG: begin
                        result_e <= Rs0[31] == 1'b1 ? 31 : Rs0[30] == 1'b1 ? 30 : Rs0[29] == 1'b1 ? 29 : Rs0[28] == 1'b1 ? 28 : Rs0[27] == 1'b1 ? 27 : Rs0[26] == 1'b1 ? 26 : Rs0[25] == 1'b1 ? 25 : Rs0[24] == 1'b1 ? 24 : Rs0[23] == 1'b1 ? 23 : Rs0[22] == 1'b1 ? 22 : Rs0[21] == 1'b1 ? 21 : Rs0[20] == 1'b1 ? 20 : Rs0[19] == 1'b1 ? 19 : Rs0[18] == 1'b1 ? 18 : Rs0[17] == 1'b1 ? 17 : Rs0[16] == 1'b1 ? 16 : Rs0[15] == 1'b1 ? 15 : Rs0[14] == 1'b1 ? 14 : Rs0[13] == 1'b1 ? 13 : Rs0[12] == 1'b1 ? 12 : Rs0[11] == 1'b1 ? 11 : Rs0[10] == 1'b1 ? 10 : Rs0[9] == 1'b1 ? 9 : Rs0[8] == 1'b1 ? 8 : Rs0[7] == 1'b1 ? 7 : Rs0[6] == 1'b1 ? 6 : Rs0[5] == 1'b1 ? 5 : Rs0[4] == 1'b1 ? 4 : Rs0[3] == 1'b1 ? 3 : Rs0[2] == 1'b1 ? 2 : Rs0[1] == 1'b1 ? 1 : Rs0[0] == 1'b1 ? 0 : 0;
                    end
                    `CTZ: begin
                        result_e <= Rs0[0] == 1'b1 ? 0 : Rs0[1] == 1'b1 ? 1 : Rs0[2] == 1'b1 ? 2 : Rs0[3] == 1'b1 ? 3 : Rs0[4] == 1'b1 ? 4 : Rs0[5] == 1'b1 ? 5 : Rs0[6] == 1'b1 ? 6 : Rs0[7] == 1'b1 ? 7 : Rs0[8] == 1'b1 ? 8 : Rs0[9] == 1'b1 ? 9 : Rs0[10] == 1'b1 ? 10 : Rs0[11] == 1'b1 ? 11 : Rs0[12] == 1'b1 ? 12 : Rs0[13] == 1'b1 ? 13 : Rs0[14] == 1'b1 ? 14 : Rs0[15] == 1'b1 ? 15 : Rs0[16] == 1'b1 ? 16 : Rs0[17] == 1'b1 ? 17 : Rs0[18] == 1'b1 ? 18 : Rs0[19] == 1'b1 ? 19 : Rs0[20] == 1'b1 ? 20 : Rs0[21] == 1'b1 ? 21 : Rs0[22] == 1'b1 ? 22 : Rs0[23] == 1'b1 ? 23 : Rs0[24] == 1'b1 ? 24 : Rs0[25] == 1'b1 ? 25 : Rs0[26] == 1'b1 ? 26 : Rs0[27] == 1'b1 ? 27 : Rs0[28] == 1'b1 ? 28 : Rs0[29] == 1'b1 ? 29 : Rs0[30] == 1'b1 ? 30 : Rs0[31] == 1'b1 ? 31 : 32;
                    end
                    `PCNT: begin
                        result_e <= Rs0[0] + Rs0[1] + Rs0[2] + Rs0[3] + Rs0[4] + Rs0[5] + Rs0[6] + Rs0[7] + Rs0[8] + Rs0[9] + Rs0[10] + Rs0[11] + Rs0[12] + Rs0[13] + Rs0[14] + Rs0[15] + Rs0[16] + Rs0[17] + Rs0[18] + Rs0[19] + Rs0[20] + Rs0[21] + Rs0[22] + Rs0[23] + Rs0[24] + Rs0[25] + Rs0[26] + Rs0[27] + Rs0[28] + Rs0[29] + Rs0[30] + Rs0[31];
                    end
                    `BRVS: begin
                        for (i = 0; i < 32; i = i+1) result_e[i] <= Rs0[31-i];
                    end
                    `SRVS: begin // TODO: is non static loop ok?
                        if (Rs1 == 0) result_e <= 32'b0;
                        else for (i = 0; i < 32; i = i+Rs1) begin
                            for (j = 0; j < Rs1; j = j+1) begin
                                result_e[i+j] <= i+Rs1-1-j < 32 ? Rs0[i+Rs1-1-j] : 1'b0;
                            end
                        end
                    end
                    `VANY: begin // TODO: is non static loop ok?
                        if (Rs1 == 0) result_e <= 32'b0;
                        else for (i = 0; i < 32; i = i+Rs1) begin
                            result_e[i] <= ((64'hFFFFFFFF << Rs1 >> 32) & Rs0 >> i) != 0;
                            for (j = 1; j < Rs1; j = j+1) result_e[i+j] <= 1'b0;
                        end
                    end
//                    `BEXT: begin
//
//                    end
//                    `BDEP: begin
//
//                    end
                    `EXS: begin
                        result_e <= Rs1 < 32
                            ? (Rs0[Rs1] ? 32'hFFFFFFFF << Rs1 : 32'b0) | ((64'hFFFFFFFF << Rs1 >> 31) & Rs0)
                        : Rs0;
                    end
                    `LSB: begin
                        result_e <= Rs0 & -Rs0;
                    end
                    `HSB: begin
                        result_e <= Rs0[31] == 1'b1 ? 32'b10000000000000000000000000000000 : Rs0[30] == 1'b1 ? 32'b1000000000000000000000000000000 : Rs0[29] == 1'b1 ? 32'b100000000000000000000000000000 : Rs0[28] == 1'b1 ? 32'b10000000000000000000000000000 : Rs0[27] == 1'b1 ? 32'b1000000000000000000000000000 : Rs0[26] == 1'b1 ? 32'b100000000000000000000000000 : Rs0[25] == 1'b1 ? 32'b10000000000000000000000000 : Rs0[24] == 1'b1 ? 32'b1000000000000000000000000 : Rs0[23] == 1'b1 ? 32'b100000000000000000000000 : Rs0[22] == 1'b1 ? 32'b10000000000000000000000 : Rs0[21] == 1'b1 ? 32'b1000000000000000000000 : Rs0[20] == 1'b1 ? 32'b100000000000000000000 : Rs0[19] == 1'b1 ? 32'b10000000000000000000 : Rs0[18] == 1'b1 ? 32'b1000000000000000000 : Rs0[17] == 1'b1 ? 32'b100000000000000000 : Rs0[16] == 1'b1 ? 32'b10000000000000000 : Rs0[15] == 1'b1 ? 32'b1000000000000000 : Rs0[14] == 1'b1 ? 32'b100000000000000 : Rs0[13] == 1'b1 ? 32'b10000000000000 : Rs0[12] == 1'b1 ? 32'b1000000000000 : Rs0[11] == 1'b1 ? 32'b100000000000 : Rs0[10] == 1'b1 ? 32'b10000000000 : Rs0[9] == 1'b1 ? 32'b1000000000 : Rs0[8] == 1'b1 ? 32'b100000000 : Rs0[7] == 1'b1 ? 32'b10000000 : Rs0[6] == 1'b1 ? 32'b1000000 : Rs0[5] == 1'b1 ? 32'b100000 : Rs0[4] == 1'b1 ? 32'b10000 : Rs0[3] == 1'b1 ? 32'b1000 : Rs0[2] == 1'b1 ? 32'b100 : Rs0[1] == 1'b1 ? 32'b10 : Rs0[0] == 1'b1 ? 32'b1 : 32'b0;
                    end
                    `LDKEY: begin
                        result_e <= keyboardOut;
                    end
                    `GCLD: begin
                        result_e <= globalCounter;
                    end
                    default begin
                        invalidFunction <= 1'b1;
                    end
                endcase
            end else if (format == `NO_WB_TRIP) begin
                case (funcID)
                    `RET: begin
                        expectedIP <= isRet_e ? stackReadOut : returnAddress[15:0];

                        stackPointer <= stackPointer - 1;
                        operationMode <= returnAddress[16];
                        isRet_e <= 1'b1;
                    end
                    `RSTKEY: begin end
                    `UGT: begin
                        generalFlag <= diff_CF && !diff_ZF;
                    end
                    `UGE: begin
                        generalFlag <= diff_CF;
                    end
                    `ULT: begin
                        generalFlag <= ~diff_CF;
                    end
                    `ULE: begin
                        generalFlag <= ~diff_CF || ~diff_ZF;
                    end
                    `SGT: begin
                        generalFlag <= ~diff_ZF && diff_NF == diff_OF;
                    end
                    `SGE: begin
                        generalFlag <= diff_NF == diff_OF;
                    end
                    `SLT: begin
                        generalFlag <= diff_NF != diff_OF;
                    end
                    `SLE: begin
                        generalFlag <= diff_ZF || diff_NF != diff_OF;
                    end
                    `EQ: begin
                        generalFlag <= diff_ZF;
                    end
                    `NE: begin
                        generalFlag <= ~diff_ZF;
                    end
                    `NF: begin
                        generalFlag <= NF;
                    end
                    `ZF: begin
                        generalFlag <= ZF;
                    end
                    `CF: begin
                        generalFlag <= CF;
                    end
                    `OF: begin
                        generalFlag <= OF;
                    end
                    `NNF: begin
                        generalFlag <= ~NF;
                    end
                    `NZF: begin
                        generalFlag <= ~ZF;
                    end
                    `NCF: begin
                        generalFlag <= ~CF;
                    end
                    `NOF: begin
                        generalFlag <= ~OF;
                    end
                    `SUSP: begin
                        halt_e <= 1'b1;
                    end
                    default begin
                        invalidFunction <= 1'b1;
                    end
                endcase
            end else if (format == `WB_QUAD) begin
                case (funcID)
//                    `VADD: begin // TODO: is non static loop ok?
//                        for (i = 0; i < 32; i = i + Rs2) begin
//
//                        end
//                    end
//                    `VSUB: begin // TODO: is non static loop ok?
//
//                    end
                    `ADDS: begin
                        result_e <= sum_shift;
                        carryFlag_e <= sum_shift[32];
                        overflowFlag_e <= (Rs0[31] == Rs1[31] && Rs0[31] != sum_shift[31]);
                    end
                    `ADDRS: begin
                        result_e <= sum_right_shift;
                        carryFlag_e <= sum_right_shift[32];
                        overflowFlag_e <= (Rs0[31] == Rs1[31] && Rs0[31] != sum_right_shift[31]);
                    end
                    `BIT: begin
                        for (i = 0; i < 32; i = i+1) result_e[i] <= Rs2[~{Rs1[i], Rs0[i]}];
                    end
                    `LD: begin
                        memAccessAddress_e <= sum[20:5];
                        memAccessNumBitsBefore_e <= sum[4:0];
                        memAccessNumBits_e <= Rs2;
                        memAccessNumBitsAfter_e <= Rs2 == 0 ? 0 : 32-Rs2-sum[4:0];
                        isMemRead_e <= 1'b1;
                    end
                    `BSF: begin
                        result_e <= Rs2 == 0 ? Rs0 : (32'hFFFFFFFF & Rs0 >> Rs1 << 32 >> Rs2) << Rs2 >> 32;
                    end
                    `BST: begin
                        result_e <= Rs2 == 0 ? Rs0 :
                            Rd >> Rs2 >> Rs1 << Rs1 << Rs2
                            | (32'hFFFFFFFF & Rs0 << 32 >> Rs2) << Rs2 >> 32
                            | (32'hFFFFFFFF & Rd << 32 >> Rs1) << Rs1 >> 32;
                    end
                    default begin
                        invalidFunction <= 1'b1;
                    end
                endcase
            end else if (format == `NO_WB_QUAD) begin
                case (funcID)
                    `ST: begin
                        memAccessAddress_e <= Rs0 + Rs1[20:5];
                        memAccessNumBitsBefore_e <= Rs1[4:0];
                        memAccessNumBits_e <= Rs2;
                        memAccessNumBitsAfter_e <= Rs2 == 0 ? 0 : 32-Rs2-Rs1[4:0];
                        isMemWrite_e <= 1'b1;
                    end
                    `STCHR: begin end
                    default begin
                        invalidFunction <= 1'b1;
                    end
                endcase
            end else if (format == `JMP) begin // jump
                case (funcID)
                    `CALL: begin
                        expectedIP <= jumpLoc;

                        stackPointer <= stackPointer + 1;
                        returnAddress <= stackWriteData; // IP_d + 1
                    end
                    `JUMP: begin
                        expectedIP <= jumpLoc;
                    end
                    default begin
                        invalidFunction <= 1'b1;
                    end
                endcase
            end
        end
    end else isValid_e_reg <= 1'b0; end end

    /*********************
     *    Memory Read    *
     *********************/
    wire stall_m = isValid_m && isValid_e && isMemWrite_m && (isMemRead_e || isMemWrite_e);

    wire fullByteWrite = isMemWrite_e && memAccessNumBits_e == 0; // 0 actually means 32 :P
    assign memAccessWren = isMemWrite_m || fullByteWrite;
    assign memAccessRden = (isMemRead_e || isMemWrite_e) && ~memAccessWren; // only read if we aren't writing
    assign memAccessAddress = isMemWrite_m ? memAccessAddress_m : memAccessAddress_e; // either write address or read address
    always @(posedge CLOCK_50) begin if (run) if (~stall_m && isValid_e) begin
        IP_m <= IP_e; // save IP of memory access instruction
        isValid_m <= 1'b1;

        sticky_m <= sticky_e;
        isWriteback_m <= isWriteback_e;
        isMemRead_m <= isMemRead_e;
        isMemWrite_m <= isMemWrite_e && ~fullByteWrite;
        Rd_m <= Rd_e;
        carryFlag_m <= carryFlag_e;
        overflowFlag_m <= overflowFlag_e;
        result_m <= result_e;

        memAccessAddress_m <= memAccessAddress;
        memAccessNumBitsBefore_m <= memAccessNumBitsBefore_e;
        memAccessNumBits_m <= memAccessNumBits_e;
        memAccessNumBitsAfter_m <= memAccessNumBitsAfter_e;

        // if we just returned, we need to update the current return address from the stack
        if (isRet_e) returnAddress <= stackReadOut;

        halt_m <= halt_e;
    end else isValid_m <= 1'b0; end

    /*********************
     *     Writeback     *
     *********************/
    wire [31:0] memOutput = memAccessWren_w && memAccessAddress_m == memAccessAddress_w ? memAccessInput_w : memAccessOutput;
    wire [31:0] finalResult_w = isMemRead_m
        ? ((memOutput << memAccessNumBitsAfter_m) >> memAccessNumBitsAfter_m) >> memAccessNumBitsBefore_m
        : result_m;

    assign memAccessInput = fullByteWrite ? (isWriteback_m && Rd_e == Rd_m ? finalResult_w : registers[Rd_e]) :
        memOutput >> memAccessNumBits_m >> memAccessNumBitsBefore_m << memAccessNumBits_m << memAccessNumBitsBefore_m
        | (32'hFFFFFFFF & registers[Rd_m] << memAccessNumBitsAfter_m << memAccessNumBitsBefore_m) >> memAccessNumBitsAfter_m
        | (32'hFFFFFFFF & memOutput << memAccessNumBitsAfter_m << memAccessNumBits_m) >> memAccessNumBitsAfter_m >> memAccessNumBits_m;
    always @(posedge CLOCK_50) begin if (run) if (isValid_m) begin
        if (halt_m) run <= 1'b0;

        if (isWriteback_m) begin
            registers[Rd_m] <= finalResult_w;

            if (sticky_m) begin
                negativeFlag <= finalResult_w[31];
                carryFlag <= carryFlag_m;
                zeroFlag <= finalResult_w == 0;
                overflowFlag <= overflowFlag_m;
            end
        end

        memAccessWren_w <= memAccessWren;
        memAccessAddress_w <= memAccessAddress;
        memAccessInput_w <= memAccessInput;
    end end
endmodule