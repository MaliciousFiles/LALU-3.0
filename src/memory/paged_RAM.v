module paged_RAM #(parameter widthad=32, parameter hwwidthad=16, parameter width=32, parameter divsize=4) (
        input                   clk,

        input [widthad-1:0]     address_a,
        input                   wren_a,
        input [width-1:0]       data_a,
        input                   rden_a,
        output [width-1:0]      q_a,

        input [widthad-1:0]     address_b,
        input                   wren_b,
        input [width-1:0]       data_b,
        input                   rden_b,
        output [width-1:0]      q_b,

        output                  stall);

        wire [widthad-(hwwidthad-divsize)-1:0] upper_addr_a = address_a[widthad-1:hwwidthad-divsize];
        wire [hwwidthad+divsize-1:0] lower_addr_a = address_a[hwwidthad-divsize-1:0];
        wire [widthad-(hwwidthad-divsize)-1:0] upper_addr_b = address_b[widthad-1:hwwidthad-divsize];
        wire [hwwidthad+divsize-1:0] lower_addr_b = address_b[hwwidthad-divsize-1:0];


        // page metadata
        reg [widthad-1:0] physicalBase [0:1<<divsize-1];
        reg elevated [0:1<<divsize-1];
        reg userExec [0:1<<divsize-1];
        reg userRead [0:1<<divsize-1];
        reg userWrite [0:1<<divsize-1];

        // page mem blocks
        wire [width-1:0] internal_q_a [0:1<<divsize-1];
        wire [width-1:0] internal_q_b [0:1<<divsize-1];
        RAM #(hwwidthad-divsize, width) blocks [0:1<<divsize-1] (
            .clk(clk),

            .address_a(lower_addr_a),
            .wren_a(upper_addr_a == physicalBase && wren_a),
            .data_a(data_a),
            .rden_a(rden_a),
            .q_a(internal_q_a),

            .address_b(address_b),
            .wren_b(upper_addr_b == physicalBase && wren_b),
            .data_b(data_b),
            .rden_b(rden_b),
            .q_b(internal_q_b));


        // evaluating the requested page index
        reg [divsize-1:0] page_idx_a, page_idx_b;
        reg page_valid_a, page_valid_b;

        reg [divsize-1:0] i;
        always @upper_addr_a begin
            page_valid_a = 0;
            for (i = 0; i < 1<<divsize; i = i+1) begin
                if (~page_valid_a && upper_addr_a == physicalBase[i]) begin
                    page_idx_a = i;
                    page_valid_a = 1;
                end else begin
                    page_idx_a = 0;
                end
            end
        end
        always @upper_addr_b begin
            page_valid_b = 0;
            for (i = 0; i < 1<<divsize; i = i+1) begin
                if (~page_valid_b && upper_addr_b == physicalBase[i]) begin
                    page_idx_b = i;
                    page_valid_b = 1;
                end else page_idx_b = 0;
            end
        end

        // output
        assign q_a = page_valid_a ? internal_q_a[page_idx_a] : 0;
        assign q_b = page_valid_b ? internal_q_b[page_idx_b] : 0;
        
        wire update_a = ~page_valid_a && (wren_a || rden_a);
        wire update_b = ~page_valid_b && (wren_b || rden_b);
        assign stall = update_a || update_b;

        // page table update TODO
        always @(posedge clk) begin
            
        end
endmodule