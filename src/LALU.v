module LALU(input CLOCK_50);

/*********************
 *  Registers/Wires  *
 *********************/
// GENERAL
reg [15:0] IP = 0;  // instruction pointer

// FETCH
reg [15:0] IP_f; // instruction pointer at fetch stage
reg [31:0] instruction; // current fetched instruction

// DECODE
wire extendedImmediate; // whether the immediate is the next instruction


// EXECUTE
wire executiveOverride; // whether to override IP with EIP
reg [15:0] expectedIP = -2; // expected instruction pointer; if incorrect, is synced with IP

// MEMORY ACCESS


// REGISTER WRITEBACK


always @(posedge CLOCK_50) begin
/*********************
 *       Fetch       *
 *********************/
IP_f <= IP; // save IP of fetched instruction

if (executiveOverride) begin // if execOverride, sync IP to EIP
    IP <= expectedIP;
end else begin               // else, increment IP
    IP <= IP + 1;
end

//instruction <=

end

endmodule