module PS2_test(CLOCK_50, PS2_CLK, PS2_DAT, KEY0, KEY1, KEY2, KEY3, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR0, LEDR1, LEDR2, LEDR3);
   /*******************************************************************************
   ** The inputs are defined here                                                **
   *******************************************************************************/
   input KEY0;
	input KEY1;
	input KEY2;
   input KEY3;
	input CLOCK_50;

   /*******************************************************************************
   ** The outputs are defined here                                               **
   *******************************************************************************/
   output [6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX2;
	output [6:0] HEX3;
	output [6:0] HEX4;
	output [6:0] HEX5;
	output reg LEDR0 = 0;
	output reg LEDR1 = 0;
	output reg LEDR2 = 0;
	output reg LEDR3 = 0;
	

   /*******************************************************************************
   ** The inouts are defined here                                                **
   *******************************************************************************/
   inout PS2_CLK;
   inout PS2_DAT;

	wire poll_print = ~KEY0;

	wire poll_raw = ~KEY1;

	wire rd_clk = ~KEY2;

	wire reset = ~KEY3;

		wire wr_clk = CLOCK_50;

	wire [11:0] ra;
	wire [11:0] wa;
	/*hex H0 (.in(data_print[3:0]), .out(HEX0));
	hex H1 (.in(data_print[7:4]), .out(HEX1));
	hex H2 (.in(data_raw[3:0]), .out(HEX2));
	hex H3 (.in(data_raw[7:4]), .out(HEX3));
	hex H4 (.in(data_raw[11:8]), .out(HEX4));
	hex H5 (.in(data_raw[15:12]), .out(HEX5));*/
	hex H0 (.in(ra[3:0]), .out(HEX0));
	hex H1 (.in(ra[7:4]), .out(HEX1));
	hex H2 (.in(wa[3:0]), .out(HEX2));
	hex H3 (.in(wa[7:4]), .out(HEX3));
	hex H4 (.in(data_print[3:0]), .out(HEX4));
	hex H5 (.in(data_print[7:4]), .out(HEX5));

	
	reg [7:0]  data_print;
	wire [7:0] dp;
	wire [15:0] dr;
   reg [15:0] data_raw;

	always @(posedge CLOCK_50) begin
		data_print <= dp;
		data_raw <= dr;
	end
	
   /*******************************************************************************
   ** The module functionality is described here                                 **
   *******************************************************************************/
   wire [7:0] ps2_data;
	wire available;

   PS2_Controller inst (
       .CLOCK_50(wr_clk),
       .reset(reset),
       .received_data(ps2_data),
       .received_data_en(available),
       .PS2_CLK(PS2_CLK),
       .PS2_DAT(PS2_DAT)
   );
	
	
	 /*********************
     *        LUT        *
     *********************/
	 reg [7:0] raw_table[0:131];
	 reg [7:0] raw_table_ex[0:125];
	 reg [15:0] ascii_table[0:93];
	 initial begin
		 raw_table[8'h01] <= 8'h0A;		// F9
		 raw_table[8'h03] <= 8'h06;		// F5
		 raw_table[8'h04] <= 8'h04;		// F3
		 raw_table[8'h05] <= 8'h02;		// F1
		 raw_table[8'h06] <= 8'h03;		// F2
		 raw_table[8'h07] <= 8'h0D;		// F12
		 raw_table[8'h09] <= 8'h0B;		// F10
		 raw_table[8'h0A] <= 8'h09;		// F8
		 raw_table[8'h0B] <= 8'h07;		// F6
		 raw_table[8'h0C] <= 8'h05;		// F4
		 raw_table[8'h0D] <= 8'h68;		// TAB
		 raw_table[8'h0E] <= 8'h35;		// `
		 raw_table[8'h11] <= 8'h2B;		// LFT ALT
		 raw_table[8'h12] <= 8'h29;		// LFT SHFT
		 raw_table[8'h14] <= 8'h2A;		// LFT CTRL
		 raw_table[8'h15] <= 8'h42;		// Q
		 raw_table[8'h16] <= 8'h36;		// 1
		 raw_table[8'h1A] <= 8'h5A;		// Z
		 raw_table[8'h1B] <= 8'h4F;		// S
		 raw_table[8'h1C] <= 8'h4E;		// A
		 raw_table[8'h1D] <= 8'h43;		// W
		 raw_table[8'h1E] <= 8'h37;		// 2
		 raw_table[8'h21] <= 8'h5C;		// C
		 raw_table[8'h22] <= 8'h5B;		// X
		 raw_table[8'h23] <= 8'h50;		// D
		 raw_table[8'h24] <= 8'h44;		// E
		 raw_table[8'h25] <= 8'h39;		// 4
		 raw_table[8'h26] <= 8'h38;		// 3
		 raw_table[8'h29] <= 8'h34;		// SPACE
		 raw_table[8'h2A] <= 8'h5D;		// V
		 raw_table[8'h2B] <= 8'h51;		// F
		 raw_table[8'h2C] <= 8'h46;		// T
		 raw_table[8'h2D] <= 8'h45;		// R
		 raw_table[8'h2E] <= 8'h3A;		// 5
		 raw_table[8'h31] <= 8'h5F;		// N
		 raw_table[8'h32] <= 8'h5E;		// B
		 raw_table[8'h33] <= 8'h53;		// H
		 raw_table[8'h34] <= 8'h52;		// G
		 raw_table[8'h35] <= 8'h47;		// Y
		 raw_table[8'h36] <= 8'h3B;		// 6
		 raw_table[8'h3A] <= 8'h60;		// M
		 raw_table[8'h3B] <= 8'h54;		// J
		 raw_table[8'h3C] <= 8'h48;		// U
		 raw_table[8'h3D] <= 8'h3C;		// 7
		 raw_table[8'h3E] <= 8'h3D;		// 8
		 raw_table[8'h41] <= 8'h61;		// ,
		 raw_table[8'h42] <= 8'h55;		// K
		 raw_table[8'h43] <= 8'h49;		// I
		 raw_table[8'h44] <= 8'h4A;		// O
		 raw_table[8'h45] <= 8'h3F;		// 0
		 raw_table[8'h46] <= 8'h3E;		// 9
		 raw_table[8'h49] <= 8'h62;		// .
		 raw_table[8'h4A] <= 8'h63;		// /
		 raw_table[8'h4B] <= 8'h56;		// L
		 raw_table[8'h4C] <= 8'h57;		// ;
		 raw_table[8'h4D] <= 8'h4B;		// P
		 raw_table[8'h4E] <= 8'h40;		// -
		 raw_table[8'h52] <= 8'h58;		// '
		 raw_table[8'h54] <= 8'h4C;		// [
		 raw_table[8'h55] <= 8'h41;		// <=
		 raw_table[8'h58] <= 8'h28;		// CAPS LCK
		 raw_table[8'h59] <= 8'h2D;		// RHT SHFT
		 raw_table[8'h5A] <= 8'h33;		// ENTER
		 raw_table[8'h5B] <= 8'h4D;		// ]
		 raw_table[8'h5D] <= 8'h59;		// \
		 raw_table[8'h66] <= 8'h32;		// BACKSPACE
		 raw_table[8'h69] <= 8'h1D;		// NUM 1
		 raw_table[8'h6B] <= 8'h20;		// NUM 4
		 raw_table[8'h6C] <= 8'h23;		// NUM 7
		 raw_table[8'h70] <= 8'h1C;		// NUM 0
		 raw_table[8'h71] <= 8'h27;		// NUM .
		 raw_table[8'h72] <= 8'h1E;		// NUM 2
		 raw_table[8'h73] <= 8'h21;		// NUM 5
		 raw_table[8'h74] <= 8'h22;		// NUM 6
		 raw_table[8'h75] <= 8'h24;		// NUM 8
		 raw_table[8'h76] <= 8'h01;		// ESC
		 raw_table[8'h77] <= 8'h17;		// NUM LCK
		 raw_table[8'h78] <= 8'h0C;		// F11
		 raw_table[8'h79] <= 8'h1B;		// NUM +
		 raw_table[8'h7A] <= 8'h1F;		// NUM 3
		 raw_table[8'h7B] <= 8'h1A;		// NUM -
		 raw_table[8'h7C] <= 8'h19;		// NUM *
		 raw_table[8'h7D] <= 8'h25;		// NUM 9
		 raw_table[8'h7E] <= 8'h0F;		// SCRL LCK
		 raw_table[8'h83] <= 8'h08;		// F7
		 raw_table_ex[8'h11] <= 8'h2F;	// RHT ALT
		 raw_table_ex[8'h14] <= 8'h2E;	// RHT CTRL
		 raw_table_ex[8'h1F] <= 8'h2C;	// LFT WIN
		 raw_table_ex[8'h27] <= 8'h30;	// RHT WIN
		 raw_table_ex[8'h4A] <= 8'h18;	// NUM /
		 raw_table_ex[8'h5A] <= 8'h26;	// NUM ENTR
		 raw_table_ex[8'h69] <= 8'h16;	// END
		 raw_table_ex[8'h6B] <= 8'h66;	// ARW LFT
		 raw_table_ex[8'h6C] <= 8'h15;	// HOME
		 raw_table_ex[8'h70] <= 8'h11;	// INSRT
		 raw_table_ex[8'h71] <= 8'h12;	// DEL
		 raw_table_ex[8'h72] <= 8'h65;	// ARW DWN
		 raw_table_ex[8'h74] <= 8'h67;	// ARW RHT
		 raw_table_ex[8'h75] <= 8'h64;	// ARW UP
		 raw_table_ex[8'h7A] <= 8'h13;	// PG DWN
		 raw_table_ex[8'h7C] <= 8'h0E;	// PRNT SCRN
		 raw_table_ex[8'h7D] <= 8'h13;	// PG UP
		 
		
		 ascii_table[8'h0D] <= 8'h0909;	// TAB
		 ascii_table[8'h0E] <= 8'h607E;	// `
		 ascii_table[8'h15] <= 8'h7151;	// Q
		 ascii_table[8'h16] <= 8'h3121;	// 1
		 ascii_table[8'h1A] <= 8'h7A51;	// Z
		 ascii_table[8'h1B] <= 8'h7353;	// S
		 ascii_table[8'h1C] <= 8'h6141;	// A
		 ascii_table[8'h1D] <= 8'h7757;	// W
		 ascii_table[8'h1E] <= 8'h3240;	// 2
		 ascii_table[8'h21] <= 8'h6343;	// C
		 ascii_table[8'h22] <= 8'h7858;	// X
		 ascii_table[8'h23] <= 8'h6444;	// D
		 ascii_table[8'h24] <= 8'h6545;	// E
		 ascii_table[8'h25] <= 8'h3424;	// 4
		 ascii_table[8'h26] <= 8'h3323;	// 3
		 ascii_table[8'h29] <= 8'h2020;	// SPACE
		 ascii_table[8'h2A] <= 8'h7656;	// V
		 ascii_table[8'h2B] <= 8'h6646;	// F
		 ascii_table[8'h2C] <= 8'h7454;	// T
		 ascii_table[8'h2D] <= 8'h7252;	// R
		 ascii_table[8'h2E] <= 8'h3525;	// 5
		 ascii_table[8'h31] <= 8'h6E4E;	// N
		 ascii_table[8'h32] <= 8'h6242;	// B
		 ascii_table[8'h33] <= 8'h6848;	// H
		 ascii_table[8'h34] <= 8'h6747;	// G
		 ascii_table[8'h35] <= 8'h7959;	// Y
		 ascii_table[8'h36] <= 8'h365E;	// 6
		 ascii_table[8'h3A] <= 8'h6D4D;	// M
		 ascii_table[8'h3B] <= 8'h6A4A;	// J
		 ascii_table[8'h3C] <= 8'h7656;	// U
		 ascii_table[8'h3D] <= 8'h3726;	// 7
		 ascii_table[8'h3E] <= 8'h382A;	// 8
		 ascii_table[8'h41] <= 8'h2C3C;	// ,
		 ascii_table[8'h42] <= 8'h6B4B;	// K
		 ascii_table[8'h43] <= 8'h6949;	// I
		 ascii_table[8'h44] <= 8'h6F4F;	// O
		 ascii_table[8'h45] <= 8'h3029;	// 0
		 ascii_table[8'h46] <= 8'h3928;	// 9
		 ascii_table[8'h49] <= 8'h2E3E;	// .
		 ascii_table[8'h4A] <= 8'h2F3F;	// /
		 ascii_table[8'h4B] <= 8'h6C4C;	// L
		 ascii_table[8'h4C] <= 8'h3B3A;	// ;
		 ascii_table[8'h4D] <= 8'h7050;	// P
		 ascii_table[8'h4E] <= 8'h2D5F;	// -
		 ascii_table[8'h52] <= 8'h2722;	// '
		 ascii_table[8'h54] <= 8'h5B7B;	// [
		 ascii_table[8'h55] <= 8'h3D2B;	// <=
		 ascii_table[8'h5A] <= 8'h0A0A;	// ENTER
		 ascii_table[8'h5B] <= 8'h5D7D;	// ]
		 ascii_table[8'h5D] <= 8'h5C7C;	// \
	 end
	 
	 
    /*********************
     *      PARSING      *
     *********************/
    reg [102:0] depressed = 0;
    reg [7:0] ascii_val = 0;
    reg [7:0] raw_val = 0;

    wire Lshft = depressed[8'h29];
    wire Lctrl = depressed[8'h2A];
    wire Lalt = depressed[8'h2B];
    wire Lwin = depressed[8'h2C];
    wire Rshft = depressed[8'h2D];
    wire Rctrl = depressed[8'h2E];
    wire Ralt = depressed[8'h2F];
    wire Rwin = depressed[8'h30];
    wire caps = depressed[8'h28];


    reg break_code = 0;
    reg ex_code = 0;
    always @(posedge wr_clk) begin
        break_code <= ps2_data == 8'hF0;
        if (ps2_data != 8'hF0) ex_code <= ps2_data == 8'hE0;

        raw_val <= ~available || break_code ? 0 : ex_code ? raw_table_ex[ps2_data] : raw_table[ps2_data];
		  ascii_val <= ~available || break_code || ex_code ? 0 : Lshft || Rshft ? ascii_table[ps2_data][7:0] : ascii_table[ps2_data][15:8];
			
			if (break_code) LEDR0 <= 1;
			if (LEDR0 && !break_code) LEDR1 <= 1;
			if (raw_val != 0) LEDR2 <= 1;
			if (ascii_val != 0) LEDR3 <= 1;
			
		  depressed[raw_val] <= !break_code;
	 end


   Keyboard_Buffer #(.WIDTH(8)) printable_buf (
        .wr_clk(wr_clk),
        .wr_data(ascii_val),
        .we(ascii_val != 0),

        .poll(poll_print),
        .reset(reset),
        .rd_clk(rd_clk),
        .rd_data(dp),
		  .ra(ra), .wa(wa)

    );

   Keyboard_Buffer #(.WIDTH(16)) raw_buf (
        .wr_clk(wr_clk),
        .wr_data({Lctrl, Lshft, Lalt, Lwin, Rctrl, Rshft, Ralt, Rwin, caps, raw_val}),
        .we(raw_val != 0),

        .poll(poll_raw),
        .reset(reset),
        .rd_clk(rd_clk),
        .rd_data(dr),
		  .ra(), .wa()
    );
endmodule