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

`ifndef __ICARUS__
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
`else
    reg[0:1024*8-1] name;
    initial name[0 +: 8] = ".";  // relativize everything

    integer nameIdx = -1;
    integer fp = 0;
    integer scratch;

    integer i, j;
    reg break;

    reg [31:0] rawRead, outData;
    assign q = outData;
    always @(posedge CLOCK_50) begin
        break = 0;
        for (i = 0; !break && i < 4; i = i+1) begin
            if (filename[i*8 +: 8] == 8'b0) begin
                if (nameIdx != -1) begin
                    name[8+(nameIdx+1)*8 +: 8] = 8'b0;

                    if (fp != 0) $fclose(fp);
                    fp = $fopen(name >> ((1024-nameIdx-2)*8), "rb+");

                    if (fp == 0) begin
                        $mkdir(name);
                        fp = $fopen(name >> ((1024-nameIdx-2)*8), "wb+");
                    end
                end

                nameIdx = -1;
                break = 1;
            end else begin
                nameIdx = nameIdx + 1;
                name[8+nameIdx*8 +: 8] = filename[24-i*8 +: 8];
            end
        end

        if (del) begin
            if (fp != 0) begin
                $fclose(fp);
                $delfile(name);
            end
            fp = 0;
            rawRead = 0;
        end

        if (fp != 0) begin
            scratch = $fseek(fp, address * 4, 0);
            if (rden) begin
                scratch = $fread(rawRead, fp);
                if (rawRead === 'bx || $feof(fp)) rawRead = 0;
                for (j = 0; j < 32; j = j+8) outData[j +: 8] = rawRead[31-j -: 8];
            end
            if (wren) $fwrite(fp, "%u", data);
        end
    end
`endif
endmodule