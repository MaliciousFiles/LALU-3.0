module saturating_counter (
    input clk,
    input modify,
    input isIncrement,
    output prediction
);
    reg [1:0] counter;
    assign prediction = counter[1];

    always @(posedge clk) if (modify) begin
        if (isIncrement) begin
            if (~(counter[1] && counter[0])) begin
                counter <= counter + 1;
            end
        end else begin
            if (counter[1] || counter[0]) begin
                counter <= counter - 1;
            end
        end
    end

endmodule