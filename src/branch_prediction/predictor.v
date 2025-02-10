module predictor (
    input CLOCK_50,
    input [15:0] IP_f,
    input wouldExecute,
    input [15:0] expectedIP,
    input wasJump, input didJump,
    output prediction
);
    parameter LOCAL_HIST_LEN    = 6;
    parameter LOCAL_HIST_IDX    = 10;
    parameter LOCAL_BIT_IDX     = 5;

    parameter GLOBAL_HIST_LEN   = 12;
    parameter GLOBAL_BIT_IDX    = 12;

    parameter META_BIT_IDX      = 10;

    reg [LOCAL_HIST_LEN-1:0] localHistTable [0:2**LOCAL_HIST_IDX-1];
    integer i;
    initial for (i = 0; i < 2**LOCAL_HIST_IDX; i = i + 1) localHistTable[i] = 0;

    wire [0:2**(LOCAL_BIT_IDX+LOCAL_HIST_LEN)-1] localPred;
    saturating_counter #(LOCAL_BIT_IDX+LOCAL_HIST_LEN) localPredCounter (
        .clk(CLOCK_50),
        .modify(WJ),
        .isIncrement(DJ),
        .modifyIdx(CLA),
        .prediction(localPred));

    wire [0:2**GLOBAL_BIT_IDX-1] globalPred;
    saturating_counter #(GLOBAL_BIT_IDX) globalPredCounter (
        .clk(CLOCK_50),
        .modify(WJ),
        .isIncrement(DJ),
        .modifyIdx(GSA),
        .prediction(globalPred));

    wire [0:2**META_BIT_IDX-1] metaPred;
    saturating_counter #(META_BIT_IDX) metaPredCounter (
        .clk(CLOCK_50),
        .modify(WJ && PL_d != PG_d),
        .isIncrement(PG_d == DJ),
        .modifyIdx(MPA),
        .prediction(metaPred));

    reg [GLOBAL_HIST_LEN-1:0] globalBranchHistory = 0;

    // fetch
    wire [LOCAL_HIST_IDX-1:0] LHA_f = IP_f[LOCAL_HIST_IDX-1:0];
    wire [LOCAL_BIT_IDX-1:0] LPA_f = IP_f[LOCAL_BIT_IDX-1:0];
    wire [LOCAL_HIST_LEN-1:0] LBH_f = localHistTable[LHA_f];
    wire [LOCAL_BIT_IDX+LOCAL_HIST_LEN-1:0] CLA_f = {LPA_f, LBH_f};
    wire PL = localPred[CLA_f];

    wire [GLOBAL_BIT_IDX-1:0] GPA_f = IP_f[GLOBAL_BIT_IDX-1:0];
    wire PG = globalPred[GPA_f ^ globalBranchHistory];

    wire [META_BIT_IDX-1:0] MPA_f = IP_f[META_BIT_IDX-1:0];
    wire PM = metaPred[MPA_f];

    assign prediction = PM ? PG : PL;

    reg PL_f = 0, PG_f = 0;
    always @(posedge CLOCK_50) begin
        PL_f <= PL;
        PG_f <= PG;
    end

    // decode
    reg PL_d = 0, PG_d = 0;
    always @(posedge CLOCK_50) begin
        PL_d <= PL_f;
        PG_d <= PG_f;
    end

    // execute
    reg [15:0] JA = 0;
    reg WJ = 0, DJ = 0;

    wire [META_BIT_IDX-1:0] MPA = JA[META_BIT_IDX-1:0];

    wire [GLOBAL_BIT_IDX-1:0] GPA = JA[GLOBAL_BIT_IDX-1:0];
    wire [GLOBAL_BIT_IDX-1:0] GSA = GPA ^ globalBranchHistory;

    wire [LOCAL_HIST_IDX-1:0] LHA = JA[LOCAL_HIST_IDX-1:0];
    wire [LOCAL_BIT_IDX-1:0] LPA = JA[LOCAL_BIT_IDX-1:0];
    wire [LOCAL_HIST_LEN-1:0] LBH = localHistTable[LHA];
    wire [LOCAL_BIT_IDX+LOCAL_HIST_LEN-1:0] CLA = {LPA, LBH};

    always @(posedge CLOCK_50) if (wouldExecute) begin
        JA <= expectedIP;
        WJ <= wasJump;
        DJ <= didJump;

        if (WJ) begin
            globalBranchHistory <= {globalBranchHistory[GLOBAL_HIST_LEN-2:0], DJ};
            localHistTable[LHA] <= {localHistTable[LHA][LOCAL_HIST_LEN-2:0], DJ};
        end
    end
endmodule