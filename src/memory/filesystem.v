module filesystem(
	input CLOCK_50,
	
	input del,
	input rden,
	input wren,
	input [31:0] filename,
	input [31:0] address,
	input [31:0] data,
	output [31:0] q,
	
	output [12:0] HPS_DDR3_ADDR, output [2:0] HPS_DDR3_BA, output HPS_DDR3_CAS_N, output HPS_DDR3_CKE, output HPS_DDR3_CK_N, output HPS_DDR3_CK_P, output HPS_DDR3_CS_N, output HPS_DDR3_DM, inout [7:0] HPS_DDR3_DQ, inout HPS_DDR3_DQS_N, inout HPS_DDR3_DQS_P, output HPS_DDR3_ODT, output HPS_DDR3_RAS_N, output HPS_DDR3_RESET_N, input HPS_DDR3_RZQ, output HPS_DDR3_WE_N);
	
	wire CLOCK_100;
	pll_clock #("100 MHz") pll (.CLOCK_50(CLOCK_50), .clk(CLOCK_100));
	
	hps_connection inst (
		.clk_clk(CLOCK_100),
		
		.read_enable_export(rden),
		.write_enable_export(wren),
		.address_export(address),
		.write_data_export(data),
		.read_data_export(q),
		.clock_export(CLOCK_50),
		.name_stream_export(filename),
		.delete_file_export(del),
		
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
endmodule