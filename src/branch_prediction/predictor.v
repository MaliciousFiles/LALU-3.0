module predictor (
    input CLOCK_50,
    input [15:0] IP_f,
    input wouldExecute,
    input [15:0] expectedIP,
    input willJump, input didJump,
    output prediction
);
    parameter LOCAL_HIST_LEN    = 6;
    parameter LOCAL_HIST_IDX    = 10;
    parameter LOCAL_BIT_IDX     = 5;

    parameter GLOBAL_HIST_LEN   = 12;
    parameter GLOBAL_BIT_IDX    = 12;

    parameter META_BIT_IDX      = 10;

    reg [LOCAL_HIST_LEN-1:0] localHistTable [0:2**LOCAL_HIST_IDX-1];

    wire localModify [0:2**LOCAL_BIT_IDX-1];
    wire localIncrement [0:2**LOCAL_BIT_IDX-1];
    wire localPred [0:2**LOCAL_BIT_IDX-1];
    saturating_counter localPredCounter [0:2**LOCAL_BIT_IDX-1] (
        .clk(CLOCK_50),
        .modify(localModify),
        .isIncrement(localIncrement),
        .prediction(localPred));
    wire globalModify [0:2**GLOBAL_BIT_IDX-1];
    wire globalIncrement [0:2**GLOBAL_BIT_IDX-1];
    wire globalPred [0:2**GLOBAL_BIT_IDX-1];
    saturating_counter globalPredCounter [0:2**GLOBAL_BIT_IDX-1] (
        .clk(CLOCK_50),
        .modify(globalModify),
        .isIncrement(globalIncrement),
        .prediction(globalPred));
    wire metaModify [0:2**META_BIT_IDX-1];
    wire metaIncrement [0:2**META_BIT_IDX-1];
    wire metaPred [0:2**META_BIT_IDX-1];
    saturating_counter metaPredCounter [0:2**META_BIT_IDX-1] (
        .clk(CLOCK_50),
        .modify(metaModify),
        .isIncrement(metaIncrement),
        .prediction(metaPred));

    reg [GLOBAL_HIST_LEN-1:0] globalBranchHistory;

    // fetch
    wire [LOCAL_HIST_IDX-1:0] LHA_f = IP_f[0:LOCAL_HIST_IDX-1];
    wire [LOCAL_BIT_IDX-1:0] LPA_f = IP_f[0:LOCAL_BIT_IDX-1];
    wire [LOCAL_HIST_LEN-1:0] LBH_f = localHistTable[LHA_f];
    wire [LOCAL_BIT_IDX+LOCAL_HIST_LEN-1:0] CLA_f = {LPA_f, LBH_f};
    wire PL = localPred[CLA_f];

    wire [GLOBAL_BIT_IDX-1:0] GPA_f = IP_f[0:GLOBAL_BIT_IDX-1];
    wire PG = globalPred[GPA_f ^ globalBranchHistory];

    wire [META_BIT_IDX-1:0] MPA_f = IP_f[0:META_BIT_IDX-1];
    wire PM = metaPred[MPA_f];

    assign prediction = PM ? PG : PL;

    reg PL_f, PG_f;
    always @(posedge CLOCK_50) begin
        PL_f <= PL;
        PG_f <= PG;
    end

    // decode
    reg PL_d, PG_d;
    always @(posedge CLOCK_50) begin
        PL_d <= PL_f;
        PG_d <= PG_f;
    end

    // execute
    reg [15:0] JA;
    reg WJ, DJ;

    wire [META_BIT_IDX-1:0] MPA = JA[0:META_BIT_IDX-1];

    wire [GLOBAL_BIT_IDX-1:0] GPA = JA[0:GLOBAL_BIT_IDX-1];
    wire [GLOBAL_BIT_IDX-1:0] GSA = GPA ^ globalBranchHistory;

    wire [LOCAL_HIST_IDX-1:0] LHA = JA[0:LOCAL_HIST_IDX-1];
    wire [LOCAL_BIT_IDX-1:0] LPA = JA[0:LOCAL_BIT_IDX-1];
    wire [LOCAL_HIST_LEN-1:0] LBH = localHistTable[LHA];
    wire [LOCAL_BIT_IDX+LOCAL_HIST_LEN-1:0] CLA = {LPA, LBH};

    integer i;
    initial begin
        for (i = 0; i < META_BIT_IDX; i = i+1) begin
            assign metaModify[i] = WJ && MPA == i && PL_d != PG_d;
            assign metaIncrement[i] = PG_d == DJ;

            assign globalModify[i] = WJ && GSA == i;
            assign globalIncrement[i] = DJ;

            assign localModify[i] = WJ && CLA == i;
            assign localIncrement[i] = DJ;
        end
    end

    always @(posedge CLOCK_50) if (wouldExecute) begin
        JA <= expectedIP;
        WJ <= willJump;
        DJ <= didJump;

        if (WJ) begin
            globalBranchHistory <= {globalBranchHistory[GLOBAL_HIST_LEN-2:0], DJ};
            localHistTable[LHA] <= {localHistTable[LHA][LOCAL_HIST_LEN-2:0], DJ};
        end
    end
endmodule