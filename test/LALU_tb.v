`timescale 1ns / 1ps
`define PERIOD 20 // 50 MHz, in a 1ns timescale

`define SIM_CYCLES 999999999 // how many clock cycles to simulate

module LALU_tb();
    // simulate the desired number of cycles
    initial #(`PERIOD*`SIM_CYCLES*2) $finish;

    // setup the clock
    reg clk = 0;
    always #`PERIOD clk = ~clk;

    wire suspended;
    always @(posedge suspended) $finish;

    // run simulation
    LALU lalu(clk, suspended);
endmodule