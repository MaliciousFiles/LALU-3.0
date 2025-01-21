`timescale 1ns/1ps

module tb();

reg CLOCK;
wire [7:0]	VGA_R;
wire [7:0]	VGA_B;
wire [7:0]	VGA_G;
wire			VGA_CLK;
wire			VGA_SYNC_N;
wire			VGA_BLANK_N;
wire			VGA_HS;
wire			VGA_VS;

wire [7:0] memData;


VGA_Test inst (
	.CLOCK_50(CLOCK),
	.VGA_R(VGA_R),
	.VGA_B(VGA_B),
	.VGA_G(VGA_G),
	.VGA_CLK(VGA_CLK),
	.VGA_SYNC_N(VGA_SYNC_N),
	.VGA_BLANK_N(VGA_BLANK_N),
	.VGA_HS(VGA_HS),
	.VGA_VS(VGA_VS),
	.memData(memData)
);

always
	#10 CLOCK = ~CLOCK;
initial
begin
	$display($time, " << Starting Simulation >> ");
	CLOCK = 1'b0;
	
	#33285000;
	$display($time, "<< Simulation Complete >>");
	$stop;
end


endmodule