
module hps_connection (
	address_export,
	clk_clk,
	clock_export,
	delete_file_export,
	h2f_reset_reset_n,
	memory_mem_a,
	memory_mem_ba,
	memory_mem_ck,
	memory_mem_ck_n,
	memory_mem_cke,
	memory_mem_cs_n,
	memory_mem_ras_n,
	memory_mem_cas_n,
	memory_mem_we_n,
	memory_mem_reset_n,
	memory_mem_dq,
	memory_mem_dqs,
	memory_mem_dqs_n,
	memory_mem_odt,
	memory_mem_dm,
	memory_oct_rzqin,
	name_stream_export,
	read_data_export,
	read_enable_export,
	reset_reset_n,
	write_data_export,
	write_enable_export);	

	input	[26:0]	address_export;
	input		clk_clk;
	input		clock_export;
	input		delete_file_export;
	output		h2f_reset_reset_n;
	output	[12:0]	memory_mem_a;
	output	[2:0]	memory_mem_ba;
	output		memory_mem_ck;
	output		memory_mem_ck_n;
	output		memory_mem_cke;
	output		memory_mem_cs_n;
	output		memory_mem_ras_n;
	output		memory_mem_cas_n;
	output		memory_mem_we_n;
	output		memory_mem_reset_n;
	inout	[7:0]	memory_mem_dq;
	inout		memory_mem_dqs;
	inout		memory_mem_dqs_n;
	output		memory_mem_odt;
	output		memory_mem_dm;
	input		memory_oct_rzqin;
	input	[31:0]	name_stream_export;
	output	[31:0]	read_data_export;
	input		read_enable_export;
	input		reset_reset_n;
	input	[31:0]	write_data_export;
	input		write_enable_export;
endmodule
