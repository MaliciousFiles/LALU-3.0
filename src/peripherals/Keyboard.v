module Keyboard (
    input CLOCK_50,
    inout PS2_CLK,
    inout PS2_DAT,

    input [7:0] query,
    output isPressed,

    input reset,
    input poll,
    output [17:0] out);
    integer i;

    // KEYCODE LUT
    reg [6:0] codes [0:131];
    reg [6:0] codes_ex [0:125];
    initial begin
        for (i = 0; i < 132; i = i + 1) codes[i] = 0;
        for (i = 0; i < 126; i = i + 1) codes_ex[i] = 0;
        for (i = 0; i < 7'h68; i = i + 1) depressed[i] = 0;

        codes[8'h01] <= 7'h0A;		// F9
        codes[8'h03] <= 7'h06;		// F5
        codes[8'h04] <= 7'h04;		// F3
        codes[8'h05] <= 7'h02;		// F1
        codes[8'h06] <= 7'h03;		// F2
        codes[8'h07] <= 7'h0D;		// F12
        codes[8'h09] <= 7'h0B;		// F10
        codes[8'h0A] <= 7'h09;		// F8
        codes[8'h0B] <= 7'h07;		// F6
        codes[8'h0C] <= 7'h05;		// F4
        codes[8'h0D] <= 7'h68;		// TAB
        codes[8'h0E] <= 7'h35;		// `
        codes[8'h11] <= 7'h2B;		// LFT ALT
        codes[8'h12] <= 7'h29;		// LFT SHFT
        codes[8'h14] <= 7'h2A;		// LFT CTRL
        codes[8'h15] <= 7'h42;		// Q
        codes[8'h16] <= 7'h36;		// 1
        codes[8'h1A] <= 7'h5A;		// Z
        codes[8'h1B] <= 7'h4F;		// S
        codes[8'h1C] <= 7'h4E;		// A
        codes[8'h1D] <= 7'h43;		// W
        codes[8'h1E] <= 7'h37;		// 2
        codes[8'h21] <= 7'h5C;		// C
        codes[8'h22] <= 7'h5B;		// X
        codes[8'h23] <= 7'h50;		// D
        codes[8'h24] <= 7'h44;		// E
        codes[8'h25] <= 7'h39;		// 4
        codes[8'h26] <= 7'h38;		// 3
        codes[8'h29] <= 7'h34;		// SPACE
        codes[8'h2A] <= 7'h5D;		// V
        codes[8'h2B] <= 7'h51;		// F
        codes[8'h2C] <= 7'h46;		// T
        codes[8'h2D] <= 7'h45;		// R
        codes[8'h2E] <= 7'h3A;		// 5
        codes[8'h31] <= 7'h5F;		// N
        codes[8'h32] <= 7'h5E;		// B
        codes[8'h33] <= 7'h53;		// H
        codes[8'h34] <= 7'h52;		// G
        codes[8'h35] <= 7'h47;		// Y
        codes[8'h36] <= 7'h3B;		// 6
        codes[8'h3A] <= 7'h60;		// M
        codes[8'h3B] <= 7'h54;		// J
        codes[8'h3C] <= 7'h48;		// U
        codes[8'h3D] <= 7'h3C;		// 7
        codes[8'h3E] <= 7'h3D;		// 8
        codes[8'h41] <= 7'h61;		// ,
        codes[8'h42] <= 7'h55;		// K
        codes[8'h43] <= 7'h49;		// I
        codes[8'h44] <= 7'h4A;		// O
        codes[8'h45] <= 7'h3F;		// 0
        codes[8'h46] <= 7'h3E;		// 9
        codes[8'h49] <= 7'h62;		// .
        codes[8'h4A] <= 7'h63;		// /
        codes[8'h4B] <= 7'h56;		// L
        codes[8'h4C] <= 7'h57;		// ;
        codes[8'h4D] <= 7'h4B;		// P
        codes[8'h4E] <= 7'h40;		// -
        codes[8'h52] <= 7'h58;		// '
        codes[8'h54] <= 7'h4C;		// [
        codes[8'h55] <= 7'h41;		// <=
        codes[8'h58] <= 7'h28;		// CAPS LCK
        codes[8'h59] <= 7'h2D;		// RHT SHFT
        codes[8'h5A] <= 7'h33;		// ENTER
        codes[8'h5B] <= 7'h4D;		// ]
        codes[8'h5D] <= 7'h59;		// \
        codes[8'h66] <= 7'h32;		// BACKSPACE
        codes[8'h69] <= 7'h1D;		// NUM 1
        codes[8'h6B] <= 7'h20;		// NUM 4
        codes[8'h6C] <= 7'h23;		// NUM 7
        codes[8'h70] <= 7'h1C;		// NUM 0
        codes[8'h71] <= 7'h27;		// NUM .
        codes[8'h72] <= 7'h1E;		// NUM 2
        codes[8'h73] <= 7'h21;		// NUM 5
        codes[8'h74] <= 7'h22;		// NUM 6
        codes[8'h75] <= 7'h24;		// NUM 8
        codes[8'h76] <= 7'h01;		// ESC
        codes[8'h77] <= 7'h17;		// NUM LCK
        codes[8'h78] <= 7'h0C;		// F11
        codes[8'h79] <= 7'h1B;		// NUM +
        codes[8'h7A] <= 7'h1F;		// NUM 3
        codes[8'h7B] <= 7'h1A;		// NUM -
        codes[8'h7C] <= 7'h19;		// NUM *
        codes[8'h7D] <= 7'h25;		// NUM 9
        codes[8'h7E] <= 7'h0F;		// SCRL LCK
        codes[8'h83] <= 7'h08;		// F7
        codes_ex[8'h11] <= 7'h2F;	// RHT ALT
        codes_ex[8'h14] <= 7'h2E;	// RHT CTRL
        codes_ex[8'h1F] <= 7'h2C;	// LFT WIN
        codes_ex[8'h27] <= 7'h30;	// RHT WIN
        codes_ex[8'h4A] <= 7'h18;	// NUM /
        codes_ex[8'h5A] <= 7'h26;	// NUM ENTR
        codes_ex[8'h69] <= 7'h16;	// END
        codes_ex[8'h6B] <= 7'h66;	// ARW LFT
        codes_ex[8'h6C] <= 7'h15;	// HOME
        codes_ex[8'h70] <= 7'h11;	// INSRT
        codes_ex[8'h71] <= 7'h12;	// DEL
        codes_ex[8'h72] <= 7'h65;	// ARW DWN
        codes_ex[8'h74] <= 7'h67;	// ARW RHT
        codes_ex[8'h75] <= 7'h64;	// ARW UP
        codes_ex[8'h7A] <= 7'h13;	// PG DWN
        codes_ex[8'h7C] <= 7'h0E;	// PRNT SCRN
        codes_ex[8'h7D] <= 7'h13;	// PG UP
    end

    // controller
    wire [7:0] data;
    wire available;

    PS2_Controller inst (
        .CLOCK_50(CLOCK_50),
        .reset(reset),
        .received_data(data),
        .received_data_en(available),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .the_command(3'b111), // TODO: this should turn on all the LEDs; check
        .send_command(1'b1));

    // handler
    reg depressed [0 : 7'h68];
    assign isPressed = depressed[query];

    reg break_code = 0;
    reg ex_code = 0;

    wire [6:0] keycode = available ? (ex_code ? codes_ex[data] : codes[data]) : 0;
    wire validPoll = poll && readIdx < writeIdx;

    always @(posedge CLOCK_50) begin
        if (reset) begin
            break_code <= 0;
            ex_code <= 0;
            writeIdx <= 0;
            readIdx <= 0;
        end else begin
            break_code <= data == 8'hF0;
            if (data != 8'hF0) ex_code <= data == 8'hE0;

            if (keycode != 0) begin
                depressed[keycode] <= ~break_code;
                writeIdx <= writeIdx + 1;
            end

            if (validPoll) readIdx <= readIdx + 1;
        end
    end

    // buffer
    wire [17:0] packet = {
        break_code,         // release flag
        depressed[7'h29],   // LSHFT
        depressed[7'h2A],   // LCTRL
        depressed[7'h2B],   // LALT
        depressed[7'h2C],   // LWIN
        depressed[7'h2D],   // RSHFT
        depressed[7'h2E],   // RCTRL
        depressed[7'h2F],   // RALT
        depressed[7'h30],   // RWIN
        depressed[7'h28],   // CAPS LCK
        depressed[7'h17],   // NUM LCK
        keycode};

    reg [11:0] writeIdx = 0, readIdx = 0;
    wire [17:0] bufOut;
    RAM #(12, 18, 1) buffer (
        .clk(CLOCK_50),

        .address_a(writeIdx),
        .wren_a(keycode != 0),
        .data_a(packet),
        .rden_a(1'b0),
        .q_a(),

        .address_b(validPoll ? readIdx + 1 : readIdx),
        .wren_b(1'b0),
        .data_b(18'b0),
        .rden_b(1'b1),
        .q_b(bufOut));

    assign out = validPoll ? bufOut : 18'b0;
endmodule