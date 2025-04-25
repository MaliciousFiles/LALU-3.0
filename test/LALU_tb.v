`timescale 10ns / 1ns // 50 MHz, in a 1ns timescale

`define SIM_CYCLES 1000000 // how many clock cycles to simulate (1000000 for ~1 VGA frame)

module LALU_tb();
    // VGA sim stuff
    initial $timeformat(-9, 0, "ns", 5);
    integer fd;
    initial fd = $fopen("output.txt","w");
    initial $fwrite(fd, "0 ns: 0 0 00000000 00000000 00000000\n");
    always @(posedge VGA_CLK) begin
        $fwrite(fd, "%0d ns: %b %b %b %b %b\n", $time*10, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B);
    end

    initial $init_fs("LALU_fs");

    // simulate the desired number of cycles
    initial #(`SIM_CYCLES*2) begin
        $cleanup_fs;
        $finish;
        $fclose(fd);
    end

    // setup the clock
    reg clk = 0;
    always #1 clk = ~clk;

    wire suspended;
    always @(posedge suspended) begin
        $cleanup_fs;
        $finish;
    end

    // run simulation
    wire PS2_CLK, PS2_DAT, VGA_CLK, VGA_SYNC_N, VGA_BLANK_N, VGA_HS, VGA_VS;
    wire [7:0] VGA_R, VGA_G, VGA_B;
    wire HPS_DDR3_ADDR, HPS_DDR3_BA, HPS_DDR3_CAS_N, HPS_DDR3_CKE, HPS_DDR3_CK_N, HPS_DDR3_CK_P, HPS_DDR3_CS_N, HPS_DDR3_DM, HPS_DDR3_DQ, HPS_DDR3_DQS_N, HPS_DDR3_DQS_P, HPS_DDR3_ODT, HPS_DDR3_RAS_N, HPS_DDR3_RESET_N, HPS_DDR3_RZQ, HPS_DDR3_WE_N;
    LALU lalu(clk, PS2_CLK, PS2_DAT, VGA_R, VGA_G, VGA_B, VGA_CLK, VGA_SYNC_N, VGA_BLANK_N, VGA_HS, VGA_VS,
        HPS_DDR3_ADDR, HPS_DDR3_BA, HPS_DDR3_CAS_N, HPS_DDR3_CKE, HPS_DDR3_CK_N, HPS_DDR3_CK_P, HPS_DDR3_CS_N, HPS_DDR3_DM, HPS_DDR3_DQ, HPS_DDR3_DQS_N, HPS_DDR3_DQS_P, HPS_DDR3_ODT, HPS_DDR3_RAS_N, HPS_DDR3_RESET_N, HPS_DDR3_RZQ, HPS_DDR3_WE_N,
        suspended);
endmodule