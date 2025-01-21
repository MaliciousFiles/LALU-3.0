module Keyboard_Buffer(	wr_clk,
								wr_data,
								we,

								poll,
								reset,
								rd_clk,
								rd_data,
								ra, wa);

	parameter WIDTH = 8;

	input			poll;
	input			reset;
	input			wr_clk;
	input			rd_clk;
	input	[WIDTH-1:0]	wr_data;
	input			we;

	output [11:0] ra;
	output [11:0] wa;
	output [WIDTH-1:0] rd_data;


	reg [WIDTH-1:0] data = 0;
	reg [11:0] wr_addr = 0;
   always @(posedge wr_clk) begin
       if (reset) begin
			wr_addr <= 0;
			data <= 0;
		 end
		 else begin
			data <= memdata;
			if (we) begin
				wr_addr <= wr_addr + 1;
			end
		 end
   end

	reg [11:0] rd_addr = 0;
	always @(posedge rd_clk) begin
		if (reset) rd_addr <= 0;
		else if (poll && rd_addr != wr_addr) rd_addr <= rd_addr + 1;
	end
	
	assign ra = rd_addr;
	assign wa = wr_addr;
	assign rd_data = poll && rd_addr != wr_addr ? data : 0;
	

	wire [WIDTH-1:0] memdata;
   altsyncram altsyncram_component (
                .address_a (wr_addr),
                .clock0 (wr_clk),
                .data_a (wr_data),
                .wren_a (we),
                .rden_a (1'b0),
                .q_a (),
                .byteena_a (1'b1),
                .addressstall_a (1'b0),
                
					 .aclr0 (1'b0),
                .aclr1 (1'b0),
                .clocken0 (1'b1),
                .clocken1 (1'b1),
                .clocken2 (1'b0),
                .clocken3 (1'b0),
                .eccstatus (),

                .address_b (rd_addr),
                .addressstall_b (1'b0),
                .byteena_b (1'b1),
                .clock1 (rd_clk),
                .data_b (),
                .q_b (memdata),
                .rden_b (1'b1),
                .wren_b (1'b0)
                );

      defparam
            altsyncram_component.clock_enable_input_a = "BYPASS",
   	      altsyncram_component.clock_enable_input_b = "BYPASS",
            altsyncram_component.clock_enable_output_a = "BYPASS",
   		   altsyncram_component.clock_enable_output_b = "BYPASS",
            altsyncram_component.intended_device_family = "Cyclone V",
            altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
            altsyncram_component.lpm_type = "altsyncram",
            altsyncram_component.numwords_a = 4096,
            altsyncram_component.numwords_b = 4096,
            altsyncram_component.operation_mode = "BIDIR_DUAL_PORT",
            altsyncram_component.outdata_aclr_a = "NONE",
            altsyncram_component.outdata_reg_a = "UNREGISTERED",
            altsyncram_component.outdata_reg_b = "UNREGISTERED",
            altsyncram_component.power_up_uninitialized = "FALSE",
            altsyncram_component.widthad_a = 12,
            altsyncram_component.widthad_b = 12,
            altsyncram_component.width_a = WIDTH,
            altsyncram_component.width_b = WIDTH,
            altsyncram_component.width_byteena_a = 1,
            altsyncram_component.width_byteena_b = 1;

endmodule
