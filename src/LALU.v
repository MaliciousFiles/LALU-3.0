module LALU(input CLOCK_50);
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
        .fetchOutput(fetchOutput),

        .memAccessAddress(memAccessAddress),
        .memAccessWren(memAccessWren),
        .memAccessData(memAccessInput),
        .memAccessRden(memAccessRden),
        .memAccessOutput(memAccessOutput));

    /*********************
     *     Registers     *
     *********************/
    // GENERAL
    reg [15:0] IP = 0; // instruction pointer
    reg operationMode = 0; // 0 = user mode, 1 = kernel mode

    reg generalFlag = 0;
    reg negativeFlag = 0;
    reg overflowFlag = 0;
    reg carryFlag = 0;
    reg zeroFlag = 0;


    // FETCH
    reg [15:0] IP_f = 0; // instruction pointer at fetch stage
    reg nop_f = 0; // whether to nop the fetch stage; reg because it is used in the next cycle


    // DECODE
    reg [15:0] IP_d = 0; // instruction pointer at decode stage

    reg extendedImmediate = 0; // whether the next instruction is an extended immediate

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
    reg isMemRead_d = 0; // whether the instruction reads from memory
    reg isWriteback_d = 0; // whether the instruction writes back to a register


    // EXECUTE
    reg [15:0] IP_e = 0; // instruction pointer at execute stage

    reg [15:0] expectedIP = -2; // expected instruction pointer; if incorrect, is synced with IP


    // MEMORY READ



    // WRITEBACK


    /*********************
     *       Fetch       *
     *********************/
    assign fetchAddress = IP; // fetch address is the current instruction pointer
    wire [31:0] instruction = (nop_f || extendedImmediate) || nop_d ? 32'b0 : fetchOutput; // current fetched instruction

    always @(posedge CLOCK_50) begin
        IP_f <= IP; // save IP of fetched instruction
        nop_f <= executiveOverride; // must nop if extended immediate

        IP <= executiveOverride
            ? expectedIP    // if execOverride, sync IP to EIP
            : IP + 1;       // else, increment IP
    end

    /*********************
     *       Decode      *
     *********************/
    wire nop_d = executiveOverride; // whether to nop the decode stage; literally sets instruction to a nop
    wire [2:0] curFormat = instruction[2:0]; // current instruction format, to know how to decode
    always @(posedge CLOCK_50) begin
        IP_d <= IP_f; // save IP of decoded instruction

        // Universal
        format <= curFormat;
        conditional <= instruction[31];
        negate <= instruction[30];
        sticky_d <= instruction[29];

        if (curFormat[1:0] == 2'b00) begin // triple
            Rd_d <= instruction[28:24];

            Rs0_d <= instruction[23:19];
            Rs1_d <= instruction[18:14];

            funcID <= instruction[13:5];

            i0 <= instruction[4];
            i1 <= instruction[3];

            extendedImmediate <= instruction[4] && instruction[23:19] == 5'b11111 || instruction[3] && instruction[18:14] == 5'b11111;

            isWriteback_d <= curFormat[2];
            isMemRead_d <= instruction[13:5] == 8'b0010_0010; // only pop

            // unused by triple
            Rs2_d <= 5'b0;
            i2 <= 1'b0;
            jumpLoc <= 21'b0;
            jumpPageLoc <= 3'b0;
        end if (curFormat[1:0] == 2'b01) begin // quad
            Rd_d <= instruction[28:24];

            Rs0_d <= instruction[23:19];
            Rs1_d <= instruction[18:14];
            Rs2_d <= instruction[13:9];

            funcID <= {5'b0, instruction[8:5]};

            i1 <= instruction[4];
            i2 <= instruction[3];

            extendedImmediate <= instruction[4] && instruction[18:14] == 5'b11111 || instruction[3] && instruction[13:9] == 5'b11111;

            isWriteback_d <= curFormat[2];
            isMemRead_d <= instruction[8:5] == 8'b0010; // only ld

            // unused by quad
            i0 <= 1'b0;
            jumpLoc <= 21'b0;
            jumpPageLoc <= 3'b0;
        end if (curFormat == 3'b110) begin // jump
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
            extendedImmediate <= 1'b0;
            isWriteback_d <= 1'b0;
            isMemRead_d <= 1'b0;
        end
    end

    /*********************
     *      Execute      *
     *********************/
    wire nop_e = executiveOverride || (conditional && generalFlag == negate); // whether to nop the execute stage
    wire executiveOverride = expectedIP != IP_d; // whether to override IP with EIP
    always @(posedge CLOCK_50) begin
        IP_e <= IP_d; // save IP of executed instruction
        expectedIP <= format == 3'b110 ? jumpLoc : expectedIP + 1; // used for course correction

        if (~nop_e) begin
            // TODO: get working reg values
            // TODO: execute
            // TODO: passthru values
        end
    end
endmodule