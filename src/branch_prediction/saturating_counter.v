module saturating_counter (
    input clk,
    input modify,
    input isIncrement,
    input [SIZE-1:0] modifyIdx,
    output [0:2**SIZE-1] prediction
);
    parameter SIZE = 1;

    reg [0:2**SIZE-1] lowerBit = 0;
    reg [0:2**SIZE-1] upperBit = 0;
    assign prediction = upperBit;

    always @(posedge clk) if (modify) begin
        if (isIncrement) begin
            if (lowerBit[modifyIdx]) begin
                upperBit[modifyIdx] <= 1'b1;
                lowerBit[modifyIdx] <= upperBit[modifyIdx];
            end else begin
                lowerBit[modifyIdx] <= 1'b1;
            end
        end else begin
            if (lowerBit[modifyIdx]) begin
                lowerBit[modifyIdx] <= 1'b0;
            end else begin
                upperBit[modifyIdx] <= 1'b0;
                lowerBit[modifyIdx] <= upperBit[modifyIdx];
            end
        end
    end

endmodule