module filesystem(
	input CLOCK_50,
	
	input swapMeta,
	input [31:0] swapAddress,
	input swapRden,
	output [31:0] swapQ,
	input swapWren,
	input [31:0] swapData,

    input [7:0] syscallId,

	input [31:0] pathPtr1,
	input [31:0] pathPtr2,
	input [31:0] fileDescriptor,
	input [31:0] fileAddress,
	input [4:0] fileBits,
	input [31:0] writeData,

	output [31:0] dataOut,
	
	output [12:0] HPS_DDR3_ADDR, output [2:0] HPS_DDR3_BA, output HPS_DDR3_CAS_N, output HPS_DDR3_CKE, output HPS_DDR3_CK_N, output HPS_DDR3_CK_P, output HPS_DDR3_CS_N, output HPS_DDR3_DM, inout [7:0] HPS_DDR3_DQ, inout HPS_DDR3_DQS_N, inout HPS_DDR3_DQS_P, output HPS_DDR3_ODT, output HPS_DDR3_RAS_N, output HPS_DDR3_RESET_N, input HPS_DDR3_RZQ, output HPS_DDR3_WE_N);

`ifndef __ICARUS__
	wire CLOCK_100;
	pll_clock #("100 MHz") pll (.CLOCK_50(CLOCK_50), .clk(CLOCK_100));

	hps_connection inst (
		.clk_clk(CLOCK_100),

        .clock_export(CLOCK_50),

		.swap_meta_export(swapMeta),
		.swap_address_export(swapAddress),
		.swap_rden_export(swapRden),
		.swap_read_data_export(swapQ),
		.swap_wren_export(swapWren),
		.swap_write_data_export(swapData),

        .syscall_id_export(syscallId),

		.path_ptr1_export(pathPtr1),
		.path_ptr2_export(pathPtr2),
		.file_descriptor_export(fileDescriptor),
		.file_address_export(fileAddress),
		.file_read_bits_export(fileBits),
		.write_data_export(writeData),
		.data_out_export(dataOut),

		.memory_mem_a(HPS_DDR3_ADDR),
		.memory_mem_ba(HPS_DDR3_BA),
		.memory_mem_ck(HPS_DDR3_CK_P),
		.memory_mem_ck_n(HPS_DDR3_CK_N),
		.memory_mem_cke(HPS_DDR3_CKE),
		.memory_mem_cs_n(HPS_DDR3_CS_N),
		.memory_mem_ras_n(HPS_DDR3_RAS_N),
		.memory_mem_cas_n(HPS_DDR3_CAS_N),
		.memory_mem_we_n(HPS_DDR3_WE_N),
		.memory_mem_reset_n(HPS_DDR3_RESET_N),
		.memory_mem_dq(HPS_DDR3_DQ),
		.memory_mem_dqs(HPS_DDR3_DQS_P),
		.memory_mem_dqs_n(HPS_DDR3_DQS_N),
		.memory_mem_odt(HPS_DDR3_ODT),
		.memory_mem_dm(HPS_DDR3_DM),
		.memory_oct_rzqin(HPS_DDR3_RZQ),
		.reset_reset_n(1'b1));
`else
    reg [63:0] tickResult;
    assign dataOut = tickResult[31:0];
    assign swapQ = tickResult[63:32];

    always @(posedge CLOCK_50) begin
        tickResult = $tick_fs(swapMeta, swapAddress, swapRden, swapWren, swapData,
            syscallId, pathPtr1, pathPtr2, fileDescriptor, fileAddress, fileBits, writeData);
    end
`endif
endmodule