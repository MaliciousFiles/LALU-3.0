`timescale 1ns / 1ps
`define PERIOD 20 // 50 MHz, in a 1ns timescale

`define SIM_CYCLES 20 // how many clock cycles to simulate

module LALU_tb();
initial begin
  $dumpfile("LALU_tb_waveform.vcd");
  $dumpvars;
end
    // simulate the desired number of cycles
    initial #(`PERIOD*`SIM_CYCLES*2) $finish;

    // setup the clock
    reg clk = 0;
    always #`PERIOD clk = ~clk;

    // run simulation
//    LALU lalu(clk);
    reg flip = 0;
    reg test = 0;
    always @(posedge clk) begin
        flip <= ~flip;

        if (flip) test <= 1;
        test <= 0;
    end
endmodule