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
     *  Registers/Wires  *
     *********************/
    // GENERAL
    reg [15:0] IP = 0; // instruction pointer
    reg operationMode = 0; // 0 = user mode, 1 = kernel mode


    // FETCH
    reg [15:0] IP_f = 0; // instruction pointer at fetch stage

    assign fetchAddress = IP; // fetch address is the current instruction pointer
    wire instruction = extendedImmediate ? 32'b0 : fetchOutput; // current fetched instruction
                                                                //    - nop the instruction if it is an extended immediate; otherwise, forward mem output
                                                                //    - not a reg because the input (IP) is already registered,
                                                                //      and this needs to be ready in one cycle (mem fetch is
                                                                //      already 1, so storing in a reg would make 2)

    // DECODE
    reg [15:0] IP_d = 0; // instruction pointer at decode stage

    reg extendedImmediate; // whether the next instruction is an extended immediate

    reg [4:0] Rd_d = 0; // destination register at decode stage

    reg [4:0] Rs0_d = 0; // source register at decode stage
    reg i0 = 0; // whether the source register is an immediate

    reg [4:0] Rs1_d = 0;
    reg i1 = 0;

    reg [4:0] Rs2_d = 0;
    reg i2 = 0;

    reg [20:0] jumpLoc = 0; // jump loc (doesn't nop if not jump, as execute only uses if jump)

    reg sticky_d = 0; // sticky flag at decode stage
    reg conditional = 0; // conditional flag
    reg negate = 0; // conditional negation flag

    reg [2:0] format = 0; // which format the instruction is in
    reg [8:0] funcID = 0; // which operation within the format (variable number of bits; 9 max)
    reg isMemAccess_d = 0; // whether the instruction is a memory access instruction
    reg isWriteback_d = 0; // whether the instruction writes back to a register


    // EXECUTE
    wire executiveOverride; // whether to override IP with EIP
    reg [15:0] expectedIP = -2; // expected instruction pointer; if incorrect, is synced with IP

    // MEMORY ACCESS



    // REGISTER WRITEBACK



    always @(posedge CLOCK_50) begin
        /*********************
         *       Fetch       *
         *********************/
        IP_f <= IP; // save IP of fetched instruction

        if (executiveOverride) begin // if execOverride, sync IP to EIP
            IP <= expectedIP;
        end else begin               // else, increment IP
            IP <= IP + 1;
        end

        /*********************
         *       Decode      *
         *********************/
         // TODO: implement
    end
endmodule