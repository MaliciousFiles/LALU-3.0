`timescale 1ns / 1ps
`define PERIOD 20 // 50 MHz, in a 1ns timescale

`define SIM_CYCLES 5000 // how many clock cycles to simulate

module LALU_tb();
    // simulate the desired number of cycles
    initial #(`PERIOD*`SIM_CYCLES*2) $finish;

    // setup the clock
    reg clk = 0;
    always #`PERIOD clk = ~clk;

    wire suspended;
    always @(posedge suspended) $finish;

    // run simulation
    wire PS2_CLK, PS2_DAT, CLOCK_25, VGA_CLK, VGA_SYNC_N, VGA_BLANK_N, VGA_HS, VGA_VS;
    wire [7:0] VGA_R, VGA_G, VGA_B;
    LALU lalu(clk, PS2_CLK, PS2_DAT, CLOCK_25, VGA_R, VGA_G, VGA_B, VGA_CLK, VGA_SYNC_N, VGA_BLANK_N, VGA_HS, VGA_VS, suspended);
endmodule