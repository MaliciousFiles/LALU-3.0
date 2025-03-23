`timescale 1ns / 1ns

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

    // simulate the desired number of cycles
    initial #(`SIM_CYCLES*2) begin
        $finish;
        $fclose(fd);
    end

    wire suspended;
    always @(posedge suspended) $finish;

    // run simulation
    wire PS2_CLK, PS2_DAT, VGA_CLK, VGA_SYNC_N, VGA_BLANK_N, VGA_HS, VGA_VS;
    wire [7:0] VGA_R, VGA_G, VGA_B;
    LALU lalu(0, PS2_CLK, PS2_DAT, VGA_R, VGA_G, VGA_B, VGA_CLK, VGA_SYNC_N, VGA_BLANK_N, VGA_HS, VGA_VS, suspended);
endmodule