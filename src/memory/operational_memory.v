module operational_memory (
    input                   clk,
    input                   operationMode,

    input [15:0]            fetchAddress,
    input                   fetchEnable,
    output [31:0]           fetchOutput,

    input [15:0]            memAccessAddress,
    input                   memAccessWren,
    input [31:0]            memAccessData,
    input                   memAccessRden,
    output [31:0]           memAccessOutput);
        wire [31:0] userOut_fetch, userOut_memAccess;
        RAM USER_MEM (
            .clk(clk),

            .address_a(fetchAddress),
            .wren_a(1'b0),
            .data_a(32'b0),
            .rden_a(fetchEnable),
            .q_a(userOut_fetch),

            .address_b(memAccessAddress),
            .wren_b(~operationMode && memAccessWren),
            .data_b(memAccessData),
            .rden_b(memAccessRden),
            .q_b(userOut_memAccess));

        wire [31:0] kernOut_fetch, kernOut_memAccess;
        RAM #(15, 32, 0, "RAM.mif") KERN_MEM (
            .clk(clk),

            .address_a(fetchAddress[14:0]),
            .wren_a(1'b0),
            .data_a(32'b0),
            .rden_a(fetchEnable),
            .q_a(kernOut_fetch),

            .address_b(memAccessAddress[14:0]),
            .wren_b(operationMode && memAccessWren),
            .data_b(memAccessData),
            .rden_b(memAccessRden),
            .q_b(kernOut_memAccess));

    assign fetchOutput = operationMode ? kernOut_fetch : userOut_fetch;
    assign memAccessOutput = operationMode ? kernOut_memAccess : userOut_memAccess;

endmodule