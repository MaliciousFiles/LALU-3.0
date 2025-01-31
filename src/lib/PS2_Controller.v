module PS2_Controller (
	input CLOCK_50,
	input reset,
	input [7:0] the_command,
	input send_command,
	inout PS2_CLK,
 	inout PS2_DAT,
	output reg [7:0] received_data = 0,
	output reg received_data_en = 0
);
    integer fp;
    integer idx;
    integer num;
    integer out;
    initial begin
        fp = $fopen("ps2.hex", "r");
        out = $fseek(fp, 0, 2);
        num = $ftell(fp)+1;
        out = $fseek(fp, 0, 0);

        idx = 0;
    end

    reg [7:0] read = 0;
    always @(posedge CLOCK_50) if (idx < num) begin
        received_data <= read;

        idx <= idx + 1;
        received_data_en <= 1;

        if (idx + 1 == num) begin
            $fclose(fp);
            received_data_en <= 0;
        end
    end

    always @(negedge CLOCK_50) if (idx < num) out = $fread(read, fp, idx);
endmodule
