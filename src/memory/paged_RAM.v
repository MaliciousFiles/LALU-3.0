module paged_RAM #(parameter widthad=32, parameter hwwidthad=16, parameter width=32, parameter divsize=6) (
        input                   clk,

        input [widthad-1:0]     address_a,  address_b,
        input                   wren_a,     wren_b,
        input [width-1:0]       data_a,     data_b,
        input                   rden_a,     rden_b,
        output [width-1:0]      q_a,        q_b,

        output                  fsAccess,
        output reg              fsRden=0,
        output reg              fsWren=0,
        output reg              fsMeta = 0,
        input  [31:0]           fsQ,
        output reg [31:0]       fsAddress=0,
        output reg [31:0]       fsData=0);

        wire [widthad-1:0] upper_addr_a = address_a[widthad-1:hwwidthad-divsize] << (hwwidthad-divsize);
        wire [hwwidthad-divsize-1:0] lower_addr_a = address_a[hwwidthad-divsize-1:0];
        wire [widthad-1:0] upper_addr_b = address_b[widthad-1:hwwidthad-divsize] << (hwwidthad-divsize);
        wire [hwwidthad-divsize-1:0] lower_addr_b = address_b[hwwidthad-divsize-1:0];

        reg [255:0] accessCounter = 0;
        reg [divsize-1:0] leastRecentlyUsed = 0;
        reg [widthad-1:0] physicalBase [0:(1<<divsize)-1];

        // page metadata
        reg [255:0] lastAccessed [0:(1<<divsize)-1];
        initial for (i = 0; i < 1<<divsize; i = i+1) lastAccessed[i] = 0;
        reg hasData [0:(1<<divsize)-1];
        initial for (i = 0; i < 1<<divsize; i = i+1) hasData[i] = 0;

        // todo: perms
        reg elevated [0:(1<<divsize)-1];
        reg userRead [0:(1<<divsize)-1];
        reg userWrite [0:(1<<divsize)-1];
        reg userExec [0:(1<<divsize)-1];

        always @(posedge clk, posedge page_valid_a, posedge page_valid_b) begin
            if ((page_valid_a && (wren_a || rden_a)) || (page_valid_b && (wren_b || rden_b))) begin
                if (page_valid_a && (wren_a || rden_a)) begin
                    if (wren_a) hasData[page_idx_a] <= 1;
                    lastAccessed[page_idx_a] = accessCounter;
                end
                if (page_valid_b && (wren_b || rden_b)) begin
                    if (wren_b) hasData[page_idx_b] <= 1;
                    lastAccessed[page_idx_b] = accessCounter;
                end

                accessCounter = accessCounter + 1;

                // if we're overflowing, just reset :(
                if (accessCounter == 0) for (i = 0; i < 1<<divsize; i = i+1) lastAccessed[i] = 0;

                for (i = 0; i < 1<<divsize; i = i+1) begin
                    if (lastAccessed[i] < lastAccessed[leastRecentlyUsed]) leastRecentlyUsed = i;
                end
            end
        end

        // page mem blocks
        wire [width-1:0] internal_q_a [0:(1<<divsize)-1];
        wire [width-1:0] internal_q_b [0:(1<<divsize)-1];

        genvar ii;
        generate
            for (ii = 0; ii < 1<<divsize; ii = ii+1) begin : blocks
                wire [width-1:0] out_a, out_b;
                assign paged_RAM.internal_q_a[ii] = out_a;
                assign paged_RAM.internal_q_b[ii] = out_b;

                // apparently have to grab these????
                wire do_update_b = paged_RAM.do_update_b;
                wire page_valid_a = paged_RAM.page_valid_a;
                wire page_valid_b = paged_RAM.page_valid_b;
                wire update_a = paged_RAM.update_a;
                wire [divsize-1:0] leastRecentlyUsed = paged_RAM.leastRecentlyUsed;
                wire [2:0] state = paged_RAM.state;
                wire [hwwidthad-divsize-1:0] readIdx = paged_RAM.readIdx;
                wire [hwwidthad-divsize-1:0] lower_addr_a = paged_RAM.lower_addr_a;
                wire [hwwidthad-divsize-1:0] lower_addr_b = paged_RAM.lower_addr_b;
                wire [widthad-1:0] upper_addr_a = paged_RAM.upper_addr_a;
                wire [widthad-1:0] upper_addr_b = paged_RAM.upper_addr_b;

                RAM #(hwwidthad-divsize, width) blocks (
                    .clk(clk),

                    .address_a(update_a ? (state == 3 ? readIdx-2 : readIdx) : lower_addr_a),
                    .wren_a((upper_addr_a == physicalBase[ii] && page_valid_a && wren_a) || (update_a && ii == leastRecentlyUsed && state == 3 && readIdx >= 2)),
                    .data_a(update_a ? fsQ : data_a),
                    .rden_a((page_valid_a && rden_a) || (update_a && state == 1)),
                    .q_a(out_a),

                    .address_b(do_update_b ? (state == 3 ? readIdx-2 : readIdx) : lower_addr_b),
                    .wren_b((upper_addr_b == physicalBase[ii] && page_valid_b && wren_b) || (do_update_b && ii == leastRecentlyUsed && state == 3 && readIdx >= 2)),
                    .data_b(do_update_b ? fsQ : data_b),
                    .rden_b((page_valid_b && rden_b) || (do_update_b && state == 1)),
                    .q_b(out_b));
            end
        endgenerate


        // evaluating the requested page index
        reg [divsize-1:0] page_idx_a, page_idx_b, old_page_idx_a, old_page_idx_b;
        reg page_valid_a, page_valid_b;

        reg [divsize:0] i;
        reg [width-1:0] old_addr_a = 1'bx, old_addr_b = 1'bx;
        always @(posedge clk) old_page_idx_a <= page_idx_a;
        always @(posedge clk, upper_addr_a) begin
            if (upper_addr_a !== old_addr_a) begin
                old_addr_a = upper_addr_a;
                page_valid_a = 0;
                for (i = 0; ~page_valid_a && i < 1<<divsize; i = i+1) begin
                    if (upper_addr_a == physicalBase[i]) begin
                        page_idx_a = i;
                        page_valid_a = 1;
                    end else page_idx_a = 0;
                end
            end
        end
        always @(posedge clk) old_page_idx_b <= page_idx_b;
        always @(posedge clk, upper_addr_b) begin
            old_page_idx_b = page_idx_b;
            if (upper_addr_b !== old_addr_b) begin
                old_addr_b = upper_addr_b;
                page_valid_b = 0;
                for (i = 0; ~page_valid_b && i < 1<<divsize; i = i+1) begin
                    if (upper_addr_b == physicalBase[i]) begin
                        page_idx_b = i;
                        page_valid_b = 1;
                    end else page_idx_b = 0;
                end
            end
        end

        // output
        assign q_a = page_valid_a ? internal_q_a[old_page_idx_a] : 0;
        assign q_b = page_valid_b ? internal_q_b[old_page_idx_b] : 0;

        wire update_a = ~page_valid_a && (wren_a || rden_a);
        wire update_b = ~page_valid_b && (wren_b || rden_b);
        assign fsAccess = update_a || update_b;

        // state machine
        reg [2:0] state = 0;
        reg [hwwidthad-divsize-1:0] readIdx = 0;
        // page table update
        wire do_update_b = update_b && ~update_a;
        always @(posedge clk) begin
            if (update_a || update_b) begin
                case (state)
                    // setup
                    0: begin
                        state <= hasData[leastRecentlyUsed] ? 1 : 3;
                        readIdx <= 0;
                        fsMeta <= 0;
                    end
                    // dump the page
                    1,2: begin
                        if (readIdx != 0) begin
                            fsWren <= 1;
                            fsAddress <= physicalBase[leastRecentlyUsed] + readIdx - 1;
                            fsData <= (do_update_b ? internal_q_b[leastRecentlyUsed] : internal_q_a[leastRecentlyUsed]);
                        end

                        // we have to actually do one more write, so just use another stage
                        if (&readIdx) begin
                            state <= 2;
                            readIdx <= 0;
                        end else if (state == 2) state <= 3; // writing to addr [-1]
                        else readIdx <= readIdx + 1;
                    end
                    // read in the new page
                    3,4: begin
                        fsWren <= 0;
                        fsRden <= 1;
                        fsAddress <= (do_update_b ? upper_addr_b : upper_addr_a) + readIdx;

                        // same as above
                        if (&readIdx) begin
                            state <= 4;
                            readIdx <= 0;
                        end else if (state == 4 && readIdx == 1) begin
                            state <= 5;
                            fsRden <= 0;
                            readIdx <= 0;
                        end else readIdx <= readIdx + 1;
                    end
                    // open /dev/memmeta
                    5: begin
                        state <= 6;
                        fsMeta <= 1;

                        if (hasData[leastRecentlyUsed]) begin
                            fsWren <= 1;
                            fsAddress <= physicalBase[leastRecentlyUsed] >> (hwwidthad-divsize);
                            fsData <= {elevated[leastRecentlyUsed], userRead[leastRecentlyUsed], userWrite[leastRecentlyUsed], userExec[leastRecentlyUsed]};
                        end
                    end
                    // dump the metadata
                    6: begin
                        fsWren <= 0;
                        fsRden <= 1;
                        fsAddress <= (do_update_b ? upper_addr_b : upper_addr_a) >> (hwwidthad-divsize);

                        state <= 7;
                    end
                    // read in the new metadata
                    7: begin
                        if (fsRden) begin
                           fsRden <= 0;
                           fsAddress <= 0;
                        end else begin
                            physicalBase[leastRecentlyUsed] <= (do_update_b ? upper_addr_b : upper_addr_a);
                            hasData[leastRecentlyUsed] <= 0;
                            elevated[leastRecentlyUsed] <= fsQ[3];
                            userRead[leastRecentlyUsed] <= fsQ[2];
                            userWrite[leastRecentlyUsed] <= fsQ[1];
                            userExec[leastRecentlyUsed] <= fsQ[0];

                            state <= 0;

                            if (do_update_b || upper_addr_b == upper_addr_a) begin
                                page_valid_b <= 1;
                                page_idx_b <= leastRecentlyUsed;
                            end
                            if (update_a || upper_addr_a == upper_addr_b) begin
                                page_valid_a <= 1;
                                page_idx_a <= leastRecentlyUsed;
                            end
                        end
                    end
                endcase
            end
        end
endmodule