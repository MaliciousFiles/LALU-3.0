module LALU(input CLOCK_50,
    inout PS2_CLK, inout PS2_DAT,
    output [7:0] VGA_R, output [7:0] VGA_G, output [7:0] VGA_B,
    output VGA_CLK, output VGA_SYNC_N, output VGA_BLANK_N, output VGA_HS, output VGA_VS,
    output [12:0] HPS_DDR3_ADDR, output [2:0] HPS_DDR3_BA, output HPS_DDR3_CAS_N, output HPS_DDR3_CKE, output HPS_DDR3_CK_N, output HPS_DDR3_CK_P, output HPS_DDR3_CS_N, output HPS_DDR3_DM, inout [7:0] HPS_DDR3_DQ, inout HPS_DDR3_DQS_N, inout HPS_DDR3_DQS_P, output HPS_DDR3_ODT, output HPS_DDR3_RAS_N, output HPS_DDR3_RESET_N, input HPS_DDR3_RZQ, output HPS_DDR3_WE_N,
	 output suspended);
    // Formats
    parameter TRIP	            = 2'b00;
    parameter WB_TRIP			= 3'b000;
    parameter NO_WB_TRIP		= 3'b100;
    
    parameter QUAD		        = 2'b01;
    parameter WB_QUAD	        = 3'b001;
    parameter NO_WB_QUAD        = 3'b101;
    
    parameter JMP		        = 3'b110;
    
    // Functions
    parameter ADD		        = 9'b0_0000_0001;
    parameter SUB		        = 9'b0_0000_0010;
    parameter RADD		        = 9'b0_0000_1101;
    parameter RSUB		        = 9'b0_0000_1110;
    parameter ADDS              = 4'b1000;
    parameter ADDRS             = 4'b1001;
    parameter CSUB		        = 9'b0_0010_0000;
    parameter MUL		        = 9'b0_0000_0011;
    parameter UUMUL		        = 9'b0_0000_1010;
    parameter ULMUL		        = 9'b0_0000_1011;
    parameter LUMUL		        = 9'b0_0000_1100;
    parameter ABS		        = 9'b0_0001_0000;
    parameter BSL	            = 9'b0_0000_0100;
    parameter BSR	            = 9'b0_0000_0101;
    parameter BRL	            = 9'b0_0000_0110;
    parameter BRR	            = 9'b0_0000_0111;
    parameter UMAX				= 9'b0_0001_0001;
    parameter UMIN				= 9'b0_0001_0010;
    parameter SMAX				= 9'b0_0001_0011;
    parameter SMIN				= 9'b0_0001_0100;
    parameter ANY	            = 9'b0_0000_1000;
    parameter LOG				= 9'b0_0001_0101;
    parameter CTZ				= 9'b0_0001_0110;
    parameter PCNT				= 9'b0_0001_0111;
    parameter BRVS				= 9'b0_0001_1000;
    parameter SRVS				= 9'b0_0001_1111;
    parameter VANY				= 9'b0_0001_1001;
    parameter VADD				= 4'b0110;
    parameter VSUB				= 4'b0111;
    parameter BEXT				= 9'b0_0001_1100;
    parameter BDEP				= 9'b0_0001_1101;
    parameter EXS				= 9'b0_0001_1110;
    parameter VLB               = 9'b0_0001_1010;
    parameter VHB               = 9'b0_0001_1011;
    parameter DAB               = 9'b0_0001_1100;
    parameter LSB				= 9'b0_0000_1111;
    parameter HSB	            = 9'b0_0000_1001;
    
    parameter BIT	            = 9'b0000;
    
    parameter LD	            = 4'b0010;
    parameter ST	            = 4'b0011;
    parameter BSF	            = 4'b0100;
    parameter BST	            = 4'b0101;
    
    parameter RET	            = 9'b0_0010_0011;
    parameter CALL		        = 2'b00;
    parameter JUMP		        = 2'b01;
    
    parameter STCHR             = 4'b0000;
    parameter LDKEY             = 9'b0_0011_0001;
    parameter KEYPR             = 9'b0_0011_0010;
    parameter RSTKEY            = 9'b0_0011_0011;
    
    parameter UGT		        = 9'b0_1000_0000;
    parameter UGE	            = 9'b0_1000_0001;
    parameter ULT	            = 9'b0_1000_0010;
    parameter ULE	            = 9'b0_1000_0011;
    parameter SGT	            = 9'b0_1000_0100;
    parameter SGE	            = 9'b0_1000_0101;
    parameter SLT	            = 9'b0_1000_0110;
    parameter SLE	            = 9'b0_1000_0111;
    parameter EQ	            = 9'b0_1000_1000;
    parameter NE	            = 9'b0_1000_1001;
    
    // all flag get func IDs start with this, used to identify a need to stall later
    parameter FLAG_GET_INSTR    = 6'b0_1001_0;
    parameter NF	            = 9'b0_1001_0000;
    parameter ZF	            = 9'b0_1001_0001;
    parameter CF	            = 9'b0_1001_0010;
    parameter OF	            = 9'b0_1001_0011;
    parameter NNF	            = 9'b0_1001_0100;
    parameter NZF	            = 9'b0_1001_0101;
    parameter NCF	            = 9'b0_1001_0110;
    parameter NOF	            = 9'b0_1001_0111;

    parameter OPF               = 9'b0_1001_1000;
    parameter DELF   			= 9'b0_1001_1001;
    parameter STF               = 4'b1010;
    parameter LDF               = 4'b1011;

    parameter GCLD				= 9'b1_1111_1111;
    parameter SUSP				= 9'b1_1111_1111;

    /*********************
     *       Clock       *
     *********************/
    wire clk;
    pll_clock #("50 MHz") pll (
        .CLOCK_50(CLOCK_50),
        .clk(clk));

    /*********************
     * Branch Predictor  *
     *********************/
    wire prediction;
    predictor PREDICTOR(
        .clk(clk),
        .IP_f(IP_f),
        .wouldExecute(~totalSuspend && ~stall_e && ~executiveOverride && isValid_d),
        .expectedIP(expectedIP),
        .wasJump(format == JMP),
        .didJump(format == JMP && ~(conditional && generalFlag == negate)),
        .prediction(prediction));


    /*********************
     *      Memory       *
     *********************/
    wire openFile, delFile;
    wire [31:0] fsQ;
	filesystem fs(
	        .CLOCK_50(CLOCK_50),

	        .del(delFile),
			.rden(pageStall ? pageFsRden : isFileMem_e && memAccessRden),
			.wren(pageStall ? pageFsWren : ((isMemWrite_m && isFileMem_m) || isFileMem_e) && memAccessWren),

			.filename(pageFsFilename),
			.address(pageStall ? pageFsAddress : memAccessAddress),
			.data(pageStall ? pageFsData : memAccessInput),

			.q(fsQ),

			.HPS_DDR3_ADDR(HPS_DDR3_ADDR), .HPS_DDR3_BA(HPS_DDR3_BA), .HPS_DDR3_CAS_N(HPS_DDR3_CAS_N), .HPS_DDR3_CKE(HPS_DDR3_CKE), .HPS_DDR3_CK_N(HPS_DDR3_CK_N), .HPS_DDR3_CK_P(HPS_DDR3_CK_P), .HPS_DDR3_CS_N(HPS_DDR3_CS_N), .HPS_DDR3_DM(HPS_DDR3_DM), .HPS_DDR3_DQ(HPS_DDR3_DQ), .HPS_DDR3_DQS_N(HPS_DDR3_DQS_N), .HPS_DDR3_DQS_P(HPS_DDR3_DQS_P), .HPS_DDR3_ODT(HPS_DDR3_ODT), .HPS_DDR3_RAS_N(HPS_DDR3_RAS_N), .HPS_DDR3_RESET_N(HPS_DDR3_RESET_N), .HPS_DDR3_RZQ(HPS_DDR3_RZQ), .HPS_DDR3_WE_N(HPS_DDR3_WE_N));
	  
    wire [31:0] fetchAddress;
    wire [31:0] fetchOutput;

    wire [31:0] memAccessAddress;
    wire memAccessWren;
    wire [31:0] memAccessInput;
    wire memAccessRden;
    wire [31:0] memAccessOutput;

    wire pageStall, pageFsRden, pageFsWren;
    wire [31:0] pageFsFilename, pageFsAddress, pageFsData;
    paged_RAM MEM(
        .clk(clk),

        .address_a(fetchAddress),
        .wren_a(1'b0),
        .data_a(32'b0),
        .rden_a(~stall_e),
        .q_a(fetchOutput),

        .address_b(memAccessAddress),
        .wren_b(memAccessWren),
        .data_b(memAccessInput),
        .rden_b(memAccessRden),
        .q_b(memAccessOutput),

        .fsAccess(pageStall),
        .fsRden(pageFsRden),
        .fsWren(pageFsWren),
        .fsQ(fsQ),
        .fsFilename(pageFsFilename),
        .fsAddress(pageFsAddress),
        .fsData(pageFsData));
//    operational_memory MEM(
//        .clk(clk),
//        .operationMode(operationMode),
//
//        .fetchAddress(fetchAddress),
//        .fetchEnable(~stall_e),
//        .fetchOutput(fetchOutput),
//
//        .memAccessAddress(memAccessAddress),
//        .memAccessWren(memAccessWren),
//        .memAccessData(memAccessInput),
//        .memAccessRden(memAccessRden),
//        .memAccessOutput(memAccessOutput));


    wire [11:0] stackReadAddr, stackWriteAddr;
    wire [32:0] stackReadOut, stackWriteData;
    wire stackWren;
    RAM #(12, 33) STACK(
        .clk(clk),

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
    wire isKeyPressed;
    wire [7:0] keyQuery;
    wire rstKeyboard;
    wire pollKeyboard;
    wire [18:0] keyboardOut;
    Keyboard keyboard (
        .clk(clk),
        .CLOCK_50(CLOCK_50),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),

        .query(keyQuery),
        .isPressed(isKeyPressed),

        .reset(rstKeyboard),
        .poll(pollKeyboard),
        .out(keyboardOut));

    wire charWr;
    wire [23:0] charWrFgColor;
    wire [23:0] charWrBgColor;
    wire [7:0] charWrCode;
    wire [7:0] charWrFlags;
    wire [5:0] charWrX;
    wire [4:0] charWrY;
    VGA vga (
        .clk(clk),
        .CLOCK_50(CLOCK_50),

        .charWr(charWr),
        .charWrFgColor(charWrFgColor),
        .charWrBgColor(charWrBgColor),
        .charWrCode(charWrCode),
        .charWrFlags(charWrFlags),
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
     *     Constants     *
     *********************/
    wire [31:0] FULL = 32'hFFFFFFFF;
    reg [31:0] VADD_MASKS [0:31];
    reg [31:0] VSUB_MASKS [0:31];
    initial begin
        VADD_MASKS[0] = 32'b10000000000000000000000000000000;
        VSUB_MASKS[0] = 32'b00000000000000000000000000000001;
        for (i = 1; i < 32; i = i + 1) begin
            VADD_MASKS[i] = 32'b0;
            VSUB_MASKS[i] = 32'b0;
            for (j = i-1; j < 32; j = j + i) VADD_MASKS[i][j] = 1'b1;
            for (j = 0; j < 32; j = j + i) VSUB_MASKS[i][j] = 1'b1;
        end
    end

    /*********************
     *     Registers     *
     *********************/
    // GENERAL
    integer globalCounter = 0; // how many cycles the processor has been running for
    always @(posedge clk) if (~totalSuspend) globalCounter <= globalCounter + 1;

    reg [31:0] IP = 0; // instruction pointer
    reg operationMode = 1; // 0 = user mode, 1 = kernel mode
    reg run = 1; // setting to 0 entirely stops the processor
    assign suspended = ~run;

    wire totalSuspend = ~run || pageStall; // in front of literally every always in the pipeline

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
    reg [31:0] IP_f = 0; // instruction pointer at fetch stage
    reg isValid_f_reg = 0; // whether the fetched instruction is valid

    // DECODE
    reg [31:0] IP_d = 0; // instruction pointer at decode stage
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
    reg [31:0] IP_e = 0; // instruction pointer at execute stage
    reg isValid_e_reg = 0; // whether the executed instruction is valid
    reg invalidFunction = 0; // if the FMT/FuncID pairing wasn't recognized
    reg [31:0] expectedIP = 0; // expected instruction pointer; if incorrect, is synced with IP

    reg [4:0] Rd_e = 0;
    reg sticky_e = 0;
    reg isWriteback_e = 0;
    reg isMemRead_e = 0;
    reg isMemWrite_e = 0;

    reg [31:0] result_e = 0;
    reg carryFlag_e = 0;
    reg overflowFlag_e = 0;

    reg [31:0] memAccessAddress_e = 0;
    reg [4:0] memAccessNumBitsBefore_e = 0;
    reg [4:0] memAccessNumBits_e = 0;
    reg [4:0] memAccessNumBitsAfter_e = 0;
    reg isFileMem_e = 0;

    reg [32:0] returnAddress = 0;
    reg isRet_e = 0;

    reg halt_e = 0;

    // MEMORY READ
    reg [31:0] IP_m = 0; // instruction pointer at memory read stage
    reg isValid_m = 0; // whether the memory read instruction is valid

    reg sticky_m = 0;
    reg isWriteback_m = 0;
    reg isMemRead_m = 0;
    reg isMemWrite_m = 0;
    reg isFileMem_m = 0;

    reg [4:0] Rd_m = 0;
    reg carryFlag_m = 0;
    reg overflowFlag_m = 0;
    reg [31:0] result_m = 0;

    reg [31:0] memAccessAddress_m = 0;
    reg [4:0] memAccessNumBitsBefore_m = 0;
    reg [4:0] memAccessNumBits_m = 0;
    reg [4:0] memAccessNumBitsAfter_m = 0;

    reg halt_m = 0;

    // WRITEBACK
    reg memAccessWren_w = 0;
    reg isFileMem_w = 0;
    reg [31:0] memAccessAddress_w = 0;
    reg [31:0] memAccessInput_w = 0;

    /*********************
     *       Fetch       *
     *********************/
    assign fetchAddress = isValid_f && curFormat == JMP && (~conditional_d || prediction) ? jumpTo : IP; // fetch address is the current instruction pointer
    wire [31:0] instruction = fetchOutput; // current fetched instruction (as used in decode)
    reg [32:0] instruction_reg = 0; // in case of stall, we don't want to lose the contents of `instruction`
    wire isValid_f = isValid_f_reg && ~extendedImmediate; // whether the fetched instruction is valid

    always @(posedge clk) begin if (~totalSuspend) if (~stall_e) begin
        IP_f <= fetchAddress; // save IP of fetched instruction

        IP <= executiveOverride
            ? expectedIP    // if execOverride, sync IP to EIP
            : fetchAddress + 1;       // else, increment IP

        isValid_f_reg <= ~executiveOverride;
    end; if (totalSuspend != instruction_reg[32]) instruction_reg <= {totalSuspend, instruction}; end

    /*********************
     *       Decode      *
     *********************/
    wire [31:0] activeInstruction = instruction_reg[32] ? instruction_reg : instruction;

    wire [31:0] jumpTo = activeInstruction[25:5];
    wire conditional_d = activeInstruction[31];
    wire [2:0] curFormat = activeInstruction[2:0]; // current instruction format, to know how to decode
    wire extendedImmediate = exImm[0] || exImm[1] || exImm[2];
    always @(posedge clk) if (~totalSuspend) updateEIP <= ~executiveOverride && isValid_f_reg;
    always @(posedge clk) begin if (~totalSuspend) if (~stall_e) begin if (~executiveOverride && isValid_f) begin
        IP_d <= IP_f; // save IP of decoded instruction
        isValid_d <= 1'b1;

        // Universal
        format <= curFormat;
        conditional <= conditional_d;
        negate <= activeInstruction[30];
        sticky_d <= activeInstruction[29];

        if (curFormat[1:0] == TRIP) begin // triple
            Rd_d <= activeInstruction[28:24];

            Rs0_d <= activeInstruction[23:19];
            Rs1_d <= activeInstruction[18:14];

            funcID <= activeInstruction[13:5];

            i0 <= activeInstruction[4];
            i1 <= activeInstruction[3];

            exImm <= {
                1'b0,
                activeInstruction[3] && activeInstruction[18:14] == 5'b11111,
                activeInstruction[4] && activeInstruction[23:19] == 5'b11111};

            isWriteback_d <= ~curFormat[2];

            // unused by triple
            Rs2_d <= 5'b0;
            i2 <= 1'b0;
            jumpLoc <= 21'b0;
            jumpPageLoc <= 3'b0;
        end else if (curFormat[1:0] == QUAD) begin // quad
            Rd_d <= activeInstruction[28:24];

            Rs0_d <= activeInstruction[23:19];
            Rs1_d <= activeInstruction[18:14];
            Rs2_d <= activeInstruction[13:9];

            funcID <= {5'b0, activeInstruction[8:5]};

            i1 <= activeInstruction[4];
            i2 <= activeInstruction[3];

            exImm <= {
                activeInstruction[3] && activeInstruction[13:9] == 5'b11111,
                activeInstruction[4] && activeInstruction[18:14] == 5'b11111,
                1'b0};

            isWriteback_d <= ~curFormat[2];

            // unused by quad
            i0 <= 1'b0;
            jumpLoc <= 21'b0;
            jumpPageLoc <= 3'b0;
        end else if (curFormat == JMP) begin // jump
            jumpPageLoc <= activeInstruction[28:26];
            jumpLoc <= jumpTo;

            funcID <= {7'b0, activeInstruction[4:3]};

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
    assign stackWren = isValid_d && format == JMP && funcID == CALL;
    assign stackWriteData = {operationMode, IP_d + 16'b1};


    wire stall_e = (isValid_d && isValid_e && isWriteback_e && isMemRead_e && ((~i0 && Rs0_d == Rd_e && format != JMP) || (~i1 && Rs1_d == Rd_e && format != JMP) || (~i2 && Rs2_d == Rd_e && format[1:0] == QUAD) || (Rd_d == Rd_e && (format == WB_QUAD && funcID == BST))))
                || (isValid_d && isValid_e && sticky_e && isWriteback_e && isMemRead_e && format == NO_WB_TRIP && funcID[8:3] == FLAG_GET_INSTR)
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
    wire [32:0] sum  = Rs0 + Rs1, sum_carry  = Rs0 + Rs1 + exec_CF, sum_shift = Rs0 + (Rs1 << Rs2), sum_right_shift = Rs0 + (Rs1 >> Rs2);
    wire [32:0] diff = Rs0 - Rs1, diff_carry = Rs0 - Rs1 + exec_CF;

    // bring out flags for all flag get instructions, with passthru
    wire exec_NF = sticky_e && isWriteback_e ? result_e[31]
        : sticky_m && isWriteback_m ? finalResult_w[31]
        : negativeFlag;
    wire exec_OF = sticky_e && isWriteback_e ? overflowFlag_e
        : sticky_m && isWriteback_m ? overflowFlag_m
        : overflowFlag;
    wire exec_CF = sticky_e && isWriteback_e ? carryFlag_e
          : sticky_m && isWriteback_m ? carryFlag_m
          : carryFlag;
    wire exec_ZF = sticky_e && isWriteback_e ? result_e == 0
        : sticky_m && isWriteback_m ? finalResult_w == 0
        : zeroFlag;

    // peripherals
    assign keyQuery = Rs0;
    assign rstKeyboard = isValid_d && format == NO_WB_TRIP && funcID == RSTKEY;
    assign pollKeyboard = isExecuting && format == WB_TRIP && funcID == LDKEY;

    assign charWr = isExecuting && format == NO_WB_QUAD && funcID == STCHR;
    assign charWrFgColor = Rs1;
    assign charWrBgColor = Rs2;
    assign charWrCode = Rd[7:0];
    assign charWrFlags = Rd[15:8];
    assign charWrX = Rs0[5:0];
    assign charWrY = Rs0[10:6];

    assign openFile = isExecuting && format == NO_WB_TRIP && funcID == OPF;
    assign delFile = isExecuting && format == NO_WB_TRIP && funcID == DELF;

    wire isExecuting = ~totalSuspend && ~stall_e && ~executiveOverride && executeInstr;
    wire executeInstr = isValid_d && ~(conditional && generalFlag == negate);
    always @(posedge clk) begin if (~totalSuspend) if (~stall_m) begin if (~stall_e && ~executiveOverride) begin
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
            isFileMem_e <= 1'b0;
            carryFlag_e <= 1'b0;
            overflowFlag_e <= 1'b0;
            isRet_e <= 1'b0;

            if (format == WB_TRIP) begin
                case (funcID)
                    ADD: begin
                        result_e <= sum[31:0];
                        carryFlag_e <= sum[32];
                        overflowFlag_e <= (Rs0[31] == Rs1[31] && Rs0[31] != sum[31]);
                    end
                    SUB: begin
                        result_e <= diff[31:0];
                        carryFlag_e <= diff[32];
                        overflowFlag_e <= (Rs0[31] != Rs1[31] && Rs0[31] != diff[31]);
                    end
                    RADD: begin
                        result_e <= sum_carry;
                        carryFlag_e <= sum_carry[32];
                        overflowFlag_e <= (Rs0[31] == Rs1[31] && Rs0[31] != sum_carry[31]);
                    end
                    RSUB: begin
                        result_e <= diff_carry;
                        carryFlag_e <= diff_carry[32];
                        overflowFlag_e <= (Rs0[31] != Rs1[31] && Rs0[31] != diff_carry[31]);
                    end
                    CSUB: begin
                        result_e <= Rs1 <= Rs0 ? diff : Rs0;
                        carryFlag_e <= Rs1 > Rs0;
                    end
                    MUL: begin
                        result_e <= Rs0[15:0] * Rs1[15:0];
                    end
                    UUMUL: begin
                        result_e <= Rs0[31:16] * Rs1[31:16];
                    end
                    ULMUL: begin
                        result_e <= Rs0[31:16] * Rs1[15:0];
                    end
                    LUMUL: begin
                        result_e <= Rs0[15:0] * Rs1[31:16];
                    end
                    ABS: begin
                        result_e <= Rs0[31] ? -Rs0 : Rs0;
                    end
                    BSL: begin
                        result_e <= Rs0 << Rs1;
                        carryFlag_e <= Rs1 == 0 ? 0 : Rs0[32-Rs1];
                    end
                    BSR: begin
                        result_e <= Rs0 >> Rs1;
                        carryFlag_e <= Rs1 == 0 ? 0 : Rs0[Rs1 -: 2];
                    end
                    BRL: begin
                        result_e <= Rs0 << Rs1 | Rs0 >> (32-Rs1);
                    end
                    BRR: begin
                        result_e <= Rs0 >> Rs1 | Rs0 << (32-Rs1);
                    end
                    UMAX: begin
                        result_e <= Rs0 > Rs1 ? Rs0 : Rs1;
                    end
                    UMIN: begin
                        result_e <= Rs0 < Rs1 ? Rs0 : Rs1;
                    end
                    SMAX: begin
                        result_e <= Rs0[31] == Rs1[31] == (Rs0 > Rs1) ? Rs0 : Rs1;
                    end
                    SMIN: begin
                        result_e <= Rs0[31] == Rs1[31] == (Rs0 < Rs1) ? Rs0 : Rs1;
                    end
                    ANY: begin
                        result_e <= Rs0 != 0;
                    end
                    LOG: begin
                        result_e <= Rs0[31] == 1'b1 ? 31 : Rs0[30] == 1'b1 ? 30 : Rs0[29] == 1'b1 ? 29 : Rs0[28] == 1'b1 ? 28 : Rs0[27] == 1'b1 ? 27 : Rs0[26] == 1'b1 ? 26 : Rs0[25] == 1'b1 ? 25 : Rs0[24] == 1'b1 ? 24 : Rs0[23] == 1'b1 ? 23 : Rs0[22] == 1'b1 ? 22 : Rs0[21] == 1'b1 ? 21 : Rs0[20] == 1'b1 ? 20 : Rs0[19] == 1'b1 ? 19 : Rs0[18] == 1'b1 ? 18 : Rs0[17] == 1'b1 ? 17 : Rs0[16] == 1'b1 ? 16 : Rs0[15] == 1'b1 ? 15 : Rs0[14] == 1'b1 ? 14 : Rs0[13] == 1'b1 ? 13 : Rs0[12] == 1'b1 ? 12 : Rs0[11] == 1'b1 ? 11 : Rs0[10] == 1'b1 ? 10 : Rs0[9] == 1'b1 ? 9 : Rs0[8] == 1'b1 ? 8 : Rs0[7] == 1'b1 ? 7 : Rs0[6] == 1'b1 ? 6 : Rs0[5] == 1'b1 ? 5 : Rs0[4] == 1'b1 ? 4 : Rs0[3] == 1'b1 ? 3 : Rs0[2] == 1'b1 ? 2 : Rs0[1] == 1'b1 ? 1 : Rs0[0] == 1'b1 ? 0 : 0;
                    end
                    CTZ: begin
                        result_e <= Rs0[0] == 1'b1 ? 0 : Rs0[1] == 1'b1 ? 1 : Rs0[2] == 1'b1 ? 2 : Rs0[3] == 1'b1 ? 3 : Rs0[4] == 1'b1 ? 4 : Rs0[5] == 1'b1 ? 5 : Rs0[6] == 1'b1 ? 6 : Rs0[7] == 1'b1 ? 7 : Rs0[8] == 1'b1 ? 8 : Rs0[9] == 1'b1 ? 9 : Rs0[10] == 1'b1 ? 10 : Rs0[11] == 1'b1 ? 11 : Rs0[12] == 1'b1 ? 12 : Rs0[13] == 1'b1 ? 13 : Rs0[14] == 1'b1 ? 14 : Rs0[15] == 1'b1 ? 15 : Rs0[16] == 1'b1 ? 16 : Rs0[17] == 1'b1 ? 17 : Rs0[18] == 1'b1 ? 18 : Rs0[19] == 1'b1 ? 19 : Rs0[20] == 1'b1 ? 20 : Rs0[21] == 1'b1 ? 21 : Rs0[22] == 1'b1 ? 22 : Rs0[23] == 1'b1 ? 23 : Rs0[24] == 1'b1 ? 24 : Rs0[25] == 1'b1 ? 25 : Rs0[26] == 1'b1 ? 26 : Rs0[27] == 1'b1 ? 27 : Rs0[28] == 1'b1 ? 28 : Rs0[29] == 1'b1 ? 29 : Rs0[30] == 1'b1 ? 30 : Rs0[31] == 1'b1 ? 31 : 32;
                    end
                    PCNT: begin
                        result_e <= Rs0[0] + Rs0[1] + Rs0[2] + Rs0[3] + Rs0[4] + Rs0[5] + Rs0[6] + Rs0[7] + Rs0[8] + Rs0[9] + Rs0[10] + Rs0[11] + Rs0[12] + Rs0[13] + Rs0[14] + Rs0[15] + Rs0[16] + Rs0[17] + Rs0[18] + Rs0[19] + Rs0[20] + Rs0[21] + Rs0[22] + Rs0[23] + Rs0[24] + Rs0[25] + Rs0[26] + Rs0[27] + Rs0[28] + Rs0[29] + Rs0[30] + Rs0[31];
                    end
                    BRVS: begin
                        for (i = 0; i < 32; i = i+1) result_e[i] <= Rs0[31-i];
                    end
                    SRVS: begin
                        case (Rs1)
                            0: for (i = 0; i < 32; i = i+1) result_e[i] <= Rs0[31-i];
                            1: result_e <= Rs0;
                            2: for (i = 0; i < 32; i = i+2) for (j = 0; j < 2; j = j+1) if (i+j < 32) result_e[i+j] <= i+1-j < 32 ? Rs0[i+1-j] : 1'b0;
                            3: for (i = 0; i < 32; i = i+3) for (j = 0; j < 3; j = j+1) if (i+j < 32) result_e[i+j] <= i+2-j < 32 ? Rs0[i+2-j] : 1'b0;
                            4: for (i = 0; i < 32; i = i+4) for (j = 0; j < 4; j = j+1) if (i+j < 32) result_e[i+j] <= i+3-j < 32 ? Rs0[i+3-j] : 1'b0;
                            5: for (i = 0; i < 32; i = i+5) for (j = 0; j < 5; j = j+1) if (i+j < 32) result_e[i+j] <= i+4-j < 32 ? Rs0[i+4-j] : 1'b0;
                            6: for (i = 0; i < 32; i = i+6) for (j = 0; j < 6; j = j+1) if (i+j < 32) result_e[i+j] <= i+5-j < 32 ? Rs0[i+5-j] : 1'b0;
                            7: for (i = 0; i < 32; i = i+7) for (j = 0; j < 7; j = j+1) if (i+j < 32) result_e[i+j] <= i+6-j < 32 ? Rs0[i+6-j] : 1'b0;
                            8: for (i = 0; i < 32; i = i+8) for (j = 0; j < 8; j = j+1) if (i+j < 32) result_e[i+j] <= i+7-j < 32 ? Rs0[i+7-j] : 1'b0;
                            9: for (i = 0; i < 32; i = i+9) for (j = 0; j < 9; j = j+1) if (i+j < 32) result_e[i+j] <= i+8-j < 32 ? Rs0[i+8-j] : 1'b0;
                            10: for (i = 0; i < 32; i = i+10) for (j = 0; j < 10; j = j+1) if (i+j < 32) result_e[i+j] <= i+9-j < 32 ? Rs0[i+9-j] : 1'b0;
                            11: for (i = 0; i < 32; i = i+11) for (j = 0; j < 11; j = j+1) if (i+j < 32) result_e[i+j] <= i+10-j < 32 ? Rs0[i+10-j] : 1'b0;
                            12: for (i = 0; i < 32; i = i+12) for (j = 0; j < 12; j = j+1) if (i+j < 32) result_e[i+j] <= i+11-j < 32 ? Rs0[i+11-j] : 1'b0;
                            13: for (i = 0; i < 32; i = i+13) for (j = 0; j < 13; j = j+1) if (i+j < 32) result_e[i+j] <= i+12-j < 32 ? Rs0[i+12-j] : 1'b0;
                            14: for (i = 0; i < 32; i = i+14) for (j = 0; j < 14; j = j+1) if (i+j < 32) result_e[i+j] <= i+13-j < 32 ? Rs0[i+13-j] : 1'b0;
                            15: for (i = 0; i < 32; i = i+15) for (j = 0; j < 15; j = j+1) if (i+j < 32) result_e[i+j] <= i+14-j < 32 ? Rs0[i+14-j] : 1'b0;
                            16: for (i = 0; i < 32; i = i+16) for (j = 0; j < 16; j = j+1) if (i+j < 32) result_e[i+j] <= i+15-j < 32 ? Rs0[i+15-j] : 1'b0;
                            17: for (i = 0; i < 32; i = i+17) for (j = 0; j < 17; j = j+1) if (i+j < 32) result_e[i+j] <= i+16-j < 32 ? Rs0[i+16-j] : 1'b0;
                            18: for (i = 0; i < 32; i = i+18) for (j = 0; j < 18; j = j+1) if (i+j < 32) result_e[i+j] <= i+17-j < 32 ? Rs0[i+17-j] : 1'b0;
                            19: for (i = 0; i < 32; i = i+19) for (j = 0; j < 19; j = j+1) if (i+j < 32) result_e[i+j] <= i+18-j < 32 ? Rs0[i+18-j] : 1'b0;
                            20: for (i = 0; i < 32; i = i+20) for (j = 0; j < 20; j = j+1) if (i+j < 32) result_e[i+j] <= i+19-j < 32 ? Rs0[i+19-j] : 1'b0;
                            21: for (i = 0; i < 32; i = i+21) for (j = 0; j < 21; j = j+1) if (i+j < 32) result_e[i+j] <= i+20-j < 32 ? Rs0[i+20-j] : 1'b0;
                            22: for (i = 0; i < 32; i = i+22) for (j = 0; j < 22; j = j+1) if (i+j < 32) result_e[i+j] <= i+21-j < 32 ? Rs0[i+21-j] : 1'b0;
                            23: for (i = 0; i < 32; i = i+23) for (j = 0; j < 23; j = j+1) if (i+j < 32) result_e[i+j] <= i+22-j < 32 ? Rs0[i+22-j] : 1'b0;
                            24: for (i = 0; i < 32; i = i+24) for (j = 0; j < 24; j = j+1) if (i+j < 32) result_e[i+j] <= i+23-j < 32 ? Rs0[i+23-j] : 1'b0;
                            25: for (i = 0; i < 32; i = i+25) for (j = 0; j < 25; j = j+1) if (i+j < 32) result_e[i+j] <= i+24-j < 32 ? Rs0[i+24-j] : 1'b0;
                            26: for (i = 0; i < 32; i = i+26) for (j = 0; j < 26; j = j+1) if (i+j < 32) result_e[i+j] <= i+25-j < 32 ? Rs0[i+25-j] : 1'b0;
                            27: for (i = 0; i < 32; i = i+27) for (j = 0; j < 27; j = j+1) if (i+j < 32) result_e[i+j] <= i+26-j < 32 ? Rs0[i+26-j] : 1'b0;
                            28: for (i = 0; i < 32; i = i+28) for (j = 0; j < 28; j = j+1) if (i+j < 32) result_e[i+j] <= i+27-j < 32 ? Rs0[i+27-j] : 1'b0;
                            29: for (i = 0; i < 32; i = i+29) for (j = 0; j < 29; j = j+1) if (i+j < 32) result_e[i+j] <= i+28-j < 32 ? Rs0[i+28-j] : 1'b0;
                            30: for (i = 0; i < 32; i = i+30) for (j = 0; j < 30; j = j+1) if (i+j < 32) result_e[i+j] <= i+29-j < 32 ? Rs0[i+29-j] : 1'b0;
                            31: for (i = 0; i < 32; i = i+31) for (j = 0; j < 31; j = j+1) if (i+j < 32) result_e[i+j] <= i+30-j < 32 ? Rs0[i+30-j] : 1'b0;
                            default: result_e <= 32'b0;
                        endcase
                    end
                    VANY: begin
                        result_e <= 32'b0;
                        case (Rs1)
                            1: result_e <= Rs0;
                            2: for (i = 0; i < 32; i = i+2) result_e[i] <= Rs0[i +: 2] != 0;
                            3: for (i = 0; i < 30; i = i+3) result_e[i] <= Rs0[i +: 3] != 0;
                            4: for (i = 0; i < 32; i = i+4) result_e[i] <= Rs0[i +: 4] != 0;
                            5: for (i = 0; i < 30; i = i+5) result_e[i] <= Rs0[i +: 5] != 0;
                            6: for (i = 0; i < 30; i = i+6) result_e[i] <= Rs0[i +: 6] != 0;
                            7: for (i = 0; i < 28; i = i+7) result_e[i] <= Rs0[i +: 7] != 0;
                            8: for (i = 0; i < 32; i = i+8) result_e[i] <= Rs0[i +: 8] != 0;
                            9: for (i = 0; i < 27; i = i+9) result_e[i] <= Rs0[i +: 9] != 0;
                            10: for (i = 0; i < 30; i = i+10) result_e[i] <= Rs0[i +: 10] != 0;
                            11: for (i = 0; i < 22; i = i+11) result_e[i] <= Rs0[i +: 11] != 0;
                            12: for (i = 0; i < 24; i = i+12) result_e[i] <= Rs0[i +: 12] != 0;
                            13: for (i = 0; i < 26; i = i+13) result_e[i] <= Rs0[i +: 13] != 0;
                            14: for (i = 0; i < 28; i = i+14) result_e[i] <= Rs0[i +: 14] != 0;
                            15: for (i = 0; i < 30; i = i+15) result_e[i] <= Rs0[i +: 15] != 0;
                            16: for (i = 0; i < 32; i = i+16) result_e[i] <= Rs0[i +: 16] != 0;
                            17: for (i = 0; i < 17; i = i+17) result_e[i] <= Rs0[i +: 17] != 0;
                            18: for (i = 0; i < 18; i = i+18) result_e[i] <= Rs0[i +: 18] != 0;
                            19: for (i = 0; i < 19; i = i+19) result_e[i] <= Rs0[i +: 19] != 0;
                            20: for (i = 0; i < 20; i = i+20) result_e[i] <= Rs0[i +: 20] != 0;
                            21: for (i = 0; i < 21; i = i+21) result_e[i] <= Rs0[i +: 21] != 0;
                            22: for (i = 0; i < 22; i = i+22) result_e[i] <= Rs0[i +: 22] != 0;
                            23: for (i = 0; i < 23; i = i+23) result_e[i] <= Rs0[i +: 23] != 0;
                            24: for (i = 0; i < 24; i = i+24) result_e[i] <= Rs0[i +: 24] != 0;
                            25: for (i = 0; i < 25; i = i+25) result_e[i] <= Rs0[i +: 25] != 0;
                            26: for (i = 0; i < 26; i = i+26) result_e[i] <= Rs0[i +: 26] != 0;
                            27: for (i = 0; i < 27; i = i+27) result_e[i] <= Rs0[i +: 27] != 0;
                            28: for (i = 0; i < 28; i = i+28) result_e[i] <= Rs0[i +: 28] != 0;
                            29: for (i = 0; i < 29; i = i+29) result_e[i] <= Rs0[i +: 29] != 0;
                            30: for (i = 0; i < 30; i = i+30) result_e[i] <= Rs0[i +: 30] != 0;
                            31: for (i = 0; i < 31; i = i+31) result_e[i] <= Rs0[i +: 31] != 0;
                        endcase
                    end
//                    BEXT: begin
//
//                    end
//                    BDEP: begin
//
//                    end
                    EXS: begin
                        result_e <= Rs1 < 32
                            ? (Rs0[Rs1] ? 32'hFFFFFFFF << Rs1 : 32'b0) | ((64'hFFFFFFFF << Rs1 >> 31) & Rs0)
                        : Rs0;
                    end
                    VLB: begin
                        result_e <= VSUB_MASKS[Rs0 & 32'h1F];
                    end
                    VHB: begin
                        result_e <= VADD_MASKS[Rs0 & 32'h1F];
                    end
                    DAB: begin
                        for (i = 0; i < 32; i = i + 4) begin
                            result_e[i +: 4] <= Rs0[i +: 4] + (Rs0[i +: 4] > 4 ? 3 : 0);
                        end
                    end
                    LSB: begin
                        result_e <= Rs0 & -Rs0;
                    end
                    HSB: begin
                        result_e <= 0;
                        for (i = 0; i < 32; i = i+1) if (Rs0[i]) result_e <= 1 << i;
                    end
                    LDKEY: begin
                        result_e <= keyboardOut;
                    end
                    KEYPR: begin
                        result_e <= isKeyPressed;
                    end
                    GCLD: begin
                        result_e <= globalCounter;
                    end
                    default begin
                        invalidFunction <= 1'b1;
                    end
                endcase
            end else if (format == NO_WB_TRIP) begin
                case (funcID)
                    RET: begin
                        expectedIP <= isRet_e ? stackReadOut : returnAddress[31:0];

                        stackPointer <= stackPointer - 1;
                        operationMode <= returnAddress[32];
                        isRet_e <= 1'b1;
                    end
                    RSTKEY: begin end
                    UGT: begin
                        generalFlag <= Rs0 > Rs1;
                    end
                    UGE: begin
                        generalFlag <= Rs0 >= Rs1;
                    end
                    ULT: begin
                        generalFlag <= Rs0 < Rs1;
                    end
                    ULE: begin
                        generalFlag <= Rs0 <= Rs1;
                    end
                    SGT: begin
                        generalFlag <= Rs0[31] == Rs1[31] == (Rs0 > Rs1);
                    end
                    SGE: begin
                        generalFlag <= Rs0[31] == Rs1[31] == (Rs0 >= Rs1);
                    end
                    SLT: begin
                        generalFlag <= Rs0[31] == Rs1[31] == (Rs0 < Rs1);
                    end
                    SLE: begin
                        generalFlag <= Rs0[31] == Rs1[31] == (Rs0 <= Rs1);
                    end
                    EQ: begin
                        generalFlag <= Rs0 == Rs1;
                    end
                    NE: begin
                        generalFlag <= Rs0 != Rs1;
                    end
                    NF: begin
                        generalFlag <= exec_NF;
                    end
                    ZF: begin
                        generalFlag <= exec_ZF;
                    end
                    CF: begin
                        generalFlag <= exec_CF;
                    end
                    OF: begin
                        generalFlag <= exec_OF;
                    end
                    NNF: begin
                        generalFlag <= ~exec_NF;
                    end
                    NZF: begin
                        generalFlag <= ~exec_ZF;
                    end
                    NCF: begin
                        generalFlag <= ~exec_CF;
                    end
                    NOF: begin
                        generalFlag <= ~exec_OF;
                    end
                    SUSP: begin
                        halt_e <= 1'b1;
                    end
                    OPF: begin end // all handled with wires
                    DELF: begin end // all handled with wires
                    default begin
                        invalidFunction <= 1'b1;
                    end
                endcase
            end else if (format == WB_QUAD) begin
                case (funcID)
                    VADD: begin
                        result_e <= ((Rs0 & ~VADD_MASKS[Rs2 & 32'h1F]) + (Rs1 & ~VADD_MASKS[Rs2 & 32'h1F])) ^ ((Rs0 & VADD_MASKS[Rs2 & 32'h1F]) ^ (Rs1 & VADD_MASKS[Rs2 & 32'h1F]));
                    end
                    VSUB: begin
                        result_e <= ((Rs0 &~ VADD_MASKS[Rs2 & 32'h1F]) + (~Rs1 &~ VADD_MASKS[Rs2 & 32'h1F]) + VSUB_MASKS[Rs2 & 32'h1F]) ^ ((Rs0 & VADD_MASKS[Rs2 & 32'h1F]) ^ (~Rs1 & VADD_MASKS[Rs2 & 32'h1F]));
                    end
                    ADDS: begin
                        result_e <= sum_shift;
                        carryFlag_e <= sum_shift[32];
                        overflowFlag_e <= (Rs0[31] == Rs1[31] && Rs0[31] != sum_shift[31]);
                    end
                    ADDRS: begin
                        result_e <= sum_right_shift;
                        carryFlag_e <= sum_right_shift[32];
                        overflowFlag_e <= (Rs0[31] == Rs1[31] && Rs0[31] != sum_right_shift[31]);
                    end
                    BIT: begin
                        for (i = 0; i < 32; i = i+1) result_e[i] <= Rs2[{Rs1[i], Rs0[i]}];
                    end
                    LDF: begin
                        memAccessAddress_e <= sum[31:5];
                        memAccessNumBitsBefore_e <= sum[4:0];
                        memAccessNumBits_e <= Rs2;
                        memAccessNumBitsAfter_e <= Rs2 == 0 ? 0 : 32-Rs2-sum[4:0];
                        isMemRead_e <= 1'b1;
                        isFileMem_e <= 1'b1;
                    end
                    LD: begin
                        memAccessAddress_e <= sum[31:5];
                        memAccessNumBitsBefore_e <= sum[4:0];
                        memAccessNumBits_e <= Rs2;
                        memAccessNumBitsAfter_e <= Rs2 == 0 ? 0 : 32-Rs2-sum[4:0];
                        isMemRead_e <= 1'b1;
                    end
//                    LDF: begin
//
//                    end
                    BSF: begin
                        result_e <= Rs2 == 0 ? Rs0 : (32'hFFFFFFFF & (64'b0 | Rs0) >> Rs1 << 32 >> Rs2) << Rs2 >> 32;
                    end
                    BST: begin
                        result_e <= Rs2 == 0 ? Rs0 :
                            Rd >> Rs2 >> Rs1 << Rs1 << Rs2
                            | (32'hFFFFFFFF & (64'b0 | Rs0) << 32 >> Rs2) << Rs2 >> 32 << Rs1
                            | (32'hFFFFFFFF & (64'b0 | Rd) << 32 >> Rs1) << Rs1 >> 32;
                    end
                    default begin
                        invalidFunction <= 1'b1;
                    end
                endcase
            end else if (format == NO_WB_QUAD) begin
                case (funcID)
                    ST: begin
                        memAccessAddress_e <= sum[31:5];
                        memAccessNumBitsBefore_e <= sum[4:0];
                        memAccessNumBits_e <= Rs2;
                        memAccessNumBitsAfter_e <= Rs2 == 0 ? 0 : 32-Rs2-sum[4:0];
                        isMemWrite_e <= 1'b1;
                    end
                    STF: begin
                        memAccessAddress_e <= sum[31:5];
                        memAccessNumBitsBefore_e <= sum[4:0];
                        memAccessNumBits_e <= Rs2;
                        memAccessNumBitsAfter_e <= Rs2 == 0 ? 0 : 32-Rs2-sum[4:0];
                        isMemWrite_e <= 1'b1;
                        isFileMem_e <= 1'b1;
                    end
                    STCHR: begin end
                    default begin
                        invalidFunction <= 1'b1;
                    end
                endcase
            end else if (format == JMP) begin // jump
                case (funcID)
                    CALL: begin
                        expectedIP <= jumpLoc;

                        stackPointer <= stackPointer + 1;
                    end
                    JUMP: begin
                        expectedIP <= jumpLoc;
                    end
                    default begin
                        invalidFunction <= 1'b1;
                    end
                endcase
            end
        end
        else isValid_e_reg <= 1'b0;
    end else isValid_e_reg <= 1'b0; end end

    /*********************
     *    Memory Read    *
     *********************/
    always @(posedge clk) if (~totalSuspend) begin
        // if we just returned, we need to update the current return address from the stack
        // we have to put some Execute stuff here so that returnAddress is only being driven once
        if (isExecuting && format == JMP && funcID == CALL) returnAddress <= stackWriteData;
        else if (~stall_m && isValid_e && isRet_e) returnAddress <= stackReadOut;
    end

    wire stall_m = isValid_m && isValid_e && isMemWrite_m && (isMemRead_e || isMemWrite_e);

    wire fullByteWrite = isMemWrite_e && memAccessNumBits_e == 0; // 0 actually means 32 :P
    assign memAccessWren = isMemWrite_m || fullByteWrite;
    assign memAccessRden = (isMemRead_e || isMemWrite_e) && ~memAccessWren; // only read if we aren't writing
    assign memAccessAddress = isMemWrite_m ? memAccessAddress_m : memAccessAddress_e; // either write address or read address
    always @(posedge clk) begin if (~totalSuspend) if (~stall_m && isValid_e) begin
        IP_m <= IP_e; // save IP of memory access instruction
        isValid_m <= 1'b1;

        sticky_m <= sticky_e;
        isWriteback_m <= isWriteback_e;
        isMemRead_m <= isMemRead_e;
        isMemWrite_m <= isMemWrite_e && ~fullByteWrite;
        isFileMem_m <= isFileMem_e;
        Rd_m <= Rd_e;
        carryFlag_m <= carryFlag_e;
        overflowFlag_m <= overflowFlag_e;
        result_m <= result_e;

        memAccessAddress_m <= memAccessAddress;
        memAccessNumBitsBefore_m <= memAccessNumBitsBefore_e;
        memAccessNumBits_m <= memAccessNumBits_e;
        memAccessNumBitsAfter_m <= memAccessNumBitsAfter_e;

        halt_m <= halt_e;
    end else isValid_m <= 1'b0; end

    /*********************
     *     Writeback     *
     *********************/
    wire [31:0] memOutput = memAccessWren_w && memAccessAddress_m == memAccessAddress_w && isFileMem_m == isFileMem_w ? memAccessInput_w : (isFileMem_m ? fsQ : memAccessOutput);
    wire [31:0] finalResult_w = isMemRead_m
        ? ((FULL & memOutput << memAccessNumBitsAfter_m) >> memAccessNumBitsAfter_m) >> memAccessNumBitsBefore_m
        : result_m;

    assign memAccessInput = fullByteWrite ? (isWriteback_m && Rd_e == Rd_m ? finalResult_w : registers[Rd_e]) :
        memOutput >> memAccessNumBits_m >> memAccessNumBitsBefore_m << memAccessNumBits_m << memAccessNumBitsBefore_m
        | (32'hFFFFFFFF & registers[Rd_m] << memAccessNumBitsAfter_m << memAccessNumBitsBefore_m) >> memAccessNumBitsAfter_m
        | (32'hFFFFFFFF & memOutput << memAccessNumBitsAfter_m << memAccessNumBits_m) >> memAccessNumBitsAfter_m >> memAccessNumBits_m;
    always @(posedge clk) begin if (~totalSuspend) if (isValid_m) begin
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
        isFileMem_w <= isFileMem_m
    end end
endmodule
