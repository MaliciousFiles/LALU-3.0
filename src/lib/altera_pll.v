//  Copyright (C) 2024 Intel Corporation. All rights reserved.
//  Your use of Intel Corporation's design tools, logic functions  
//  and other software and tools, and any partner logic  
//  functions, and any output files from any of the foregoing  
//  (including device programming or simulation files), and any  
//  associated documentation or information are expressly subject  
//  to the terms and conditions of the Intel Program License  
//  Subscription Agreement, the Intel Quartus Prime License Agreement, 
//  the Intel FPGA IP License Agreement, or other applicable license 
//  agreement, including, without limitation, that your use is for 
//  the sole purpose of programming logic devices manufactured by 
//  Intel and sold by Intel or its authorized distributors.  Please 
//  refer to the applicable agreement for further details, at 
//  https://fpgasoftware.intel.com/eula. 
//  
//  Quartus Prime 23.1.1 Build 993 05/14/2024 
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.

`timescale 1ps/1ps
module altera_pll
#(
    //parameter
    parameter reference_clock_frequency       = "0 ps",
	parameter fractional_vco_multiplier       = "false",
    parameter pll_type                        = "General",
    parameter pll_subtype                     = "General",
    parameter number_of_clocks                   = 1,
    parameter operation_mode                  = "internal feedback",
    parameter deserialization_factor           = 4,
    parameter data_rate                       = 0,
    
    parameter sim_additional_refclk_cycles_to_lock      = 0,
    parameter output_clock_frequency0           = "0 ps",
    parameter phase_shift0                      = "0 ps",
    parameter duty_cycle0                      = 50,
    
    parameter output_clock_frequency1           = "0 ps",
    parameter phase_shift1                      = "0 ps",
    parameter duty_cycle1                      = 50,
    
    parameter output_clock_frequency2           = "0 ps",
    parameter phase_shift2                      = "0 ps",
    parameter duty_cycle2                      = 50,
    
    parameter output_clock_frequency3           = "0 ps",
    parameter phase_shift3                      = "0 ps",
    parameter duty_cycle3                      = 50,
    
    parameter output_clock_frequency4           = "0 ps",
    parameter phase_shift4                      = "0 ps",
    parameter duty_cycle4                      = 50,
    
    parameter output_clock_frequency5           = "0 ps",
    parameter phase_shift5                      = "0 ps",
    parameter duty_cycle5                      = 50,
    
    parameter output_clock_frequency6           = "0 ps",
    parameter phase_shift6                      = "0 ps",
    parameter duty_cycle6                      = 50,
    
    parameter output_clock_frequency7           = "0 ps",
    parameter phase_shift7                      = "0 ps",
    parameter duty_cycle7                      = 50,
    
    parameter output_clock_frequency8           = "0 ps",
    parameter phase_shift8                      = "0 ps",
    parameter duty_cycle8                      = 50,
    
    parameter output_clock_frequency9           = "0 ps",
    parameter phase_shift9                      = "0 ps",
    parameter duty_cycle9                      = 50,    

    
    parameter output_clock_frequency10           = "0 ps",
    parameter phase_shift10                      = "0 ps",
    parameter duty_cycle10                      = 50,
    
    parameter output_clock_frequency11           = "0 ps",
    parameter phase_shift11                      = "0 ps",
    parameter duty_cycle11                      = 50,
    
    parameter output_clock_frequency12           = "0 ps",
    parameter phase_shift12                      = "0 ps",
    parameter duty_cycle12                      = 50,
    
    parameter output_clock_frequency13           = "0 ps",
    parameter phase_shift13                      = "0 ps",
    parameter duty_cycle13                      = 50,
    
    parameter output_clock_frequency14           = "0 ps",
    parameter phase_shift14                      = "0 ps",
    parameter duty_cycle14                      = 50,
    
    parameter output_clock_frequency15           = "0 ps",
    parameter phase_shift15                      = "0 ps",
    parameter duty_cycle15                      = 50,
    
    parameter output_clock_frequency16           = "0 ps",
    parameter phase_shift16                      = "0 ps",
    parameter duty_cycle16                      = 50,
    
    parameter output_clock_frequency17           = "0 ps",
    parameter phase_shift17                      = "0 ps",
    parameter duty_cycle17                      = 50,
    
    parameter clock_name_0 = "",
    parameter clock_name_1 = "",
    parameter clock_name_2 = "",
    parameter clock_name_3 = "",
    parameter clock_name_4 = "",
    parameter clock_name_5 = "",
    parameter clock_name_6 = "",
    parameter clock_name_7 = "",
    parameter clock_name_8 = "",

    parameter clock_name_global_0 = "false",
    parameter clock_name_global_1 = "false",
    parameter clock_name_global_2 = "false",
    parameter clock_name_global_3 = "false",
    parameter clock_name_global_4 = "false",
    parameter clock_name_global_5 = "false",
    parameter clock_name_global_6 = "false",
    parameter clock_name_global_7 = "false",
    parameter clock_name_global_8 = "false",

    parameter m_cnt_hi_div                       = 1,
    parameter m_cnt_lo_div                       = 1,
    parameter m_cnt_bypass_en                   = "false",
    parameter m_cnt_odd_div_duty_en           = "false",
    parameter n_cnt_hi_div                       = 1,
    parameter n_cnt_lo_div                       = 1,
    parameter n_cnt_bypass_en                   = "false",
    parameter n_cnt_odd_div_duty_en           = "false",
    parameter c_cnt_hi_div0                      = 1, 
    parameter c_cnt_lo_div0                      = 1,
    parameter c_cnt_bypass_en0                  = "false",
	parameter c_cnt_in_src0                     = "ph_mux_clk",
    parameter c_cnt_odd_div_duty_en0              = "false",
    parameter c_cnt_prst0                  = 1,
    parameter c_cnt_ph_mux_prst0                  = 0,
    parameter c_cnt_hi_div1                      = 1, 
    parameter c_cnt_lo_div1                      = 1,
    parameter c_cnt_bypass_en1                  = "false",
	parameter c_cnt_in_src1                     = "ph_mux_clk",
    parameter c_cnt_odd_div_duty_en1              = "false",
    parameter c_cnt_prst1                  = 1,
    parameter c_cnt_ph_mux_prst1                  = 0,
    parameter c_cnt_hi_div2                      = 1, 
    parameter c_cnt_lo_div2                                              = 1,
    parameter c_cnt_bypass_en2                  = "false",
	parameter c_cnt_in_src2                     = "ph_mux_clk",
    parameter c_cnt_odd_div_duty_en2 = "false",
    parameter c_cnt_prst2                  = 1,
    parameter c_cnt_ph_mux_prst2                  = 0,
    parameter c_cnt_hi_div3                      = 1, 
    parameter c_cnt_lo_div3                                              = 1,
    parameter c_cnt_bypass_en3                  = "false",
	parameter c_cnt_in_src3                     = "ph_mux_clk",
    parameter c_cnt_odd_div_duty_en3 = "false",
    parameter c_cnt_prst3                  = 1,
    parameter c_cnt_ph_mux_prst3                  = 0,
    parameter c_cnt_hi_div4                      = 1, 
    parameter c_cnt_lo_div4                                              = 1,
    parameter c_cnt_bypass_en4                  = "false",
	parameter c_cnt_in_src4                     = "ph_mux_clk",
    parameter c_cnt_odd_div_duty_en4 = "false",
    parameter c_cnt_prst4                  = 1,
    parameter c_cnt_ph_mux_prst4                  = 0,
    parameter c_cnt_hi_div5                      = 1, 
    parameter c_cnt_lo_div5                                              = 1,
    parameter c_cnt_bypass_en5                  = "false",
	parameter c_cnt_in_src5                     = "ph_mux_clk",
    parameter c_cnt_odd_div_duty_en5 = "false",
    parameter c_cnt_prst5                  = 1,
    parameter c_cnt_ph_mux_prst5                  = 0,
    parameter c_cnt_hi_div6                      = 1, 
    parameter c_cnt_lo_div6                                              = 1,
    parameter c_cnt_bypass_en6                  = "false",
	parameter c_cnt_in_src6                     = "ph_mux_clk",
    parameter c_cnt_odd_div_duty_en6 = "false",
    parameter c_cnt_prst6                  = 1,
    parameter c_cnt_ph_mux_prst6                  = 0,
    parameter c_cnt_hi_div7                      = 1, 
    parameter c_cnt_lo_div7                                              = 1,
    parameter c_cnt_bypass_en7                  = "false",
	parameter c_cnt_in_src7                     = "ph_mux_clk",
    parameter c_cnt_odd_div_duty_en7 = "false",
    parameter c_cnt_prst7                  = 1,
    parameter c_cnt_ph_mux_prst7                  = 0,
    parameter c_cnt_hi_div8                      = 1, 
    parameter c_cnt_lo_div8                                              = 1,
    parameter c_cnt_bypass_en8                  = "false",
	parameter c_cnt_in_src8                     = "ph_mux_clk",
    parameter c_cnt_odd_div_duty_en8 = "false",
    parameter c_cnt_prst8                  = 1,
    parameter c_cnt_ph_mux_prst8                  = 0,
    parameter c_cnt_hi_div9                      = 1, 
    parameter c_cnt_lo_div9                                              = 1,
    parameter c_cnt_bypass_en9                  = "false",
	parameter c_cnt_in_src9                     = "ph_mux_clk",
    parameter c_cnt_odd_div_duty_en9 = "false",
    parameter c_cnt_prst9                  = 1,
    parameter c_cnt_ph_mux_prst9                  = 0,
    parameter c_cnt_hi_div10                      = 1, 
    parameter c_cnt_lo_div10                                              = 1,
    parameter c_cnt_bypass_en10                  = "false",
	parameter c_cnt_in_src10                     = "ph_mux_clk",
    parameter c_cnt_odd_div_duty_en10 = "false",
    parameter c_cnt_prst10                  = 1,
    parameter c_cnt_ph_mux_prst10                  = 0,
    parameter c_cnt_hi_div11                      = 1, 
    parameter c_cnt_lo_div11                                              = 1,
    parameter c_cnt_bypass_en11                  = "false",
	parameter c_cnt_in_src11                     = "ph_mux_clk",
    parameter c_cnt_odd_div_duty_en11 = "false",
    parameter c_cnt_prst11                  = 1,
    parameter c_cnt_ph_mux_prst11                  = 0,
    parameter c_cnt_hi_div12                      = 1, 
    parameter c_cnt_lo_div12                                              = 1,
    parameter c_cnt_bypass_en12                  = "false",
	parameter c_cnt_in_src12                     = "ph_mux_clk",
    parameter c_cnt_odd_div_duty_en12 = "false",
    parameter c_cnt_prst12                  = 1,
    parameter c_cnt_ph_mux_prst12                  = 0,
    parameter c_cnt_hi_div13                      = 1, 
    parameter c_cnt_lo_div13                                              = 1,
    parameter c_cnt_bypass_en13                  = "false",
	parameter c_cnt_in_src13                     = "ph_mux_clk",
    parameter c_cnt_odd_div_duty_en13 = "false",
    parameter c_cnt_prst13                  = 1,
    parameter c_cnt_ph_mux_prst13                  = 0,
    parameter c_cnt_hi_div14                      = 1, 
    parameter c_cnt_lo_div14                                              = 1,
    parameter c_cnt_bypass_en14                  = "false",
	parameter c_cnt_in_src14                     = "ph_mux_clk",
    parameter c_cnt_odd_div_duty_en14 = "false",
    parameter c_cnt_prst14                  = 1,
    parameter c_cnt_ph_mux_prst14                  = 0,
    parameter c_cnt_hi_div15                      = 1, 
    parameter c_cnt_lo_div15                                              = 1,
    parameter c_cnt_bypass_en15                  = "false",
	parameter c_cnt_in_src15                     = "ph_mux_clk",
    parameter c_cnt_odd_div_duty_en15 = "false",
    parameter c_cnt_prst15                  = 1,
    parameter c_cnt_ph_mux_prst15                  = 0,
    parameter c_cnt_hi_div16                      = 1, 
    parameter c_cnt_lo_div16                                              = 1,
    parameter c_cnt_bypass_en16                  = "false",
	parameter c_cnt_in_src16                     = "ph_mux_clk",
    parameter c_cnt_odd_div_duty_en16 = "false",
    parameter c_cnt_prst16                  = 1,
    parameter c_cnt_ph_mux_prst16                  = 0,
    parameter c_cnt_hi_div17                      = 1, 
    parameter c_cnt_lo_div17                                              = 1,
    parameter c_cnt_bypass_en17                  = "false",
	parameter c_cnt_in_src17                     = "ph_mux_clk",
    parameter c_cnt_odd_div_duty_en17 = "false",
    parameter c_cnt_prst17                  = 1,
    parameter c_cnt_ph_mux_prst17                  = 0,
    parameter pll_vco_div = 1,
	parameter pll_slf_rst = "false",
	parameter pll_bw_sel = "low",
    parameter pll_output_clk_frequency = "0 MHz",
    parameter pll_cp_current = 0,
    parameter pll_bwctrl = 0,
    parameter pll_fractional_division = 1,
    parameter pll_fractional_cout = 24,
    parameter pll_dsm_out_sel = "1st_order",
    parameter mimic_fbclk_type = "gclk",
    parameter pll_fbclk_mux_1 = "glb",
    parameter pll_fbclk_mux_2 = "fb_1",
    parameter pll_m_cnt_in_src = "ph_mux_clk",
	parameter pll_vcoph_div = 1,
    parameter refclk1_frequency = "0 MHz",
    parameter pll_clkin_0_src = "clk_0",
    parameter pll_clkin_1_src = "clk_0",
    parameter pll_clk_loss_sw_en = "false",
    parameter pll_auto_clk_sw_en = "false",
    parameter pll_manu_clk_sw_en = "false", 
    parameter pll_clk_sw_dly = 0,
    parameter pll_extclk_0_cnt_src = "pll_extclk_cnt_src_vss",	
    parameter pll_extclk_1_cnt_src = "pll_extclk_cnt_src_vss"
   // parameter clock_switchover_mode           = "Auto",
    //parameter clock_switchover_delay           = 3,
) ( 

    //input
    input    refclk,
    input    refclk1,
    input    fbclk,
    input    rst,
    input    phase_en,
    input    updn,
    input    [2:0] num_phase_shifts,
    input    scanclk,
    input    [4:0] cntsel,
    input    [63:0] reconfig_to_pll,
    input    extswitch,
    input    adjpllin,
    input    cclk,
    
    //output
    output    [ number_of_clocks -1 : 0] outclk,
    output    fboutclk,
    output    locked,
    output    phase_done,
    output    [63:0]    reconfig_from_pll,
    output    activeclk,
    output    [1:0] clkbad,
	output    [7:0] phout,
	output	  [1:0] lvds_clk,
	output	  [1:0] loaden,
	output    [1:0] extclk_out,
    output    [ number_of_clocks -1 : 0] cascade_out,

    //inout
    inout zdbfbclk
    
);


// synthesis translate off
import altera_lnsim_functions::*;
// synthesis translate on


// synthesis translate off
`ifdef PLL_FRAC_ABSTRACT
localparam using_khz                    = 1;
`else
localparam using_khz                    =   ( fractional_vco_multiplier == "false" ) ? 1 :
											use_khz_values
											(
                                                output_clock_frequency0,
                                                output_clock_frequency1,
                                                output_clock_frequency2,
                                                output_clock_frequency3,
                                                output_clock_frequency4,
                                                output_clock_frequency5,
                                                output_clock_frequency6,
                                                output_clock_frequency7,
                                                output_clock_frequency8,
                                                output_clock_frequency9,
                                                output_clock_frequency10,
                                                output_clock_frequency11,
                                                output_clock_frequency12,
                                                output_clock_frequency13,
                                                output_clock_frequency14,
                                                output_clock_frequency15,
                                                output_clock_frequency16,
                                                output_clock_frequency17,
                                                number_of_clocks,
												reference_clock_frequency
											);
`endif

localparam MAX_STRING_LENGTH             = 20;
localparam pll_frequency_parameter		= compute_pll_frequency
                                            (
                                                output_clock_frequency0,
                                                output_clock_frequency1,
                                                output_clock_frequency2,
                                                output_clock_frequency3,
                                                output_clock_frequency4,
                                                output_clock_frequency5,
                                                output_clock_frequency6,
                                                output_clock_frequency7,
                                                output_clock_frequency8,
                                                output_clock_frequency9,
                                                output_clock_frequency10,
                                                output_clock_frequency11,
                                                output_clock_frequency12,
                                                output_clock_frequency13,
                                                output_clock_frequency14,
                                                output_clock_frequency15,
                                                output_clock_frequency16,
                                                output_clock_frequency17,
                                                number_of_clocks,
												reference_clock_frequency,
												using_khz
                                            );

localparam use_old_model                = is_period(output_clock_frequency0);

// synthesis translate on



//wire
//Signals needed for Ext DPS ports mode
wire final_phase_en;
wire dps_atpgmode;
wire dps_mdio_dis;
wire dps_scanen;
wire dps_ser_shift_load;
wire dps_write/*synthesis keep*/;
wire [5:0] dps_address;
wire [1:0] dps_byteen;
wire [15:0] dps_writedata/*synthesis keep*/;
        
////////////////////////////////////////
wire [63:0] reconfig_from_pll_wire;
wire [ number_of_clocks -1 :0] fboutclk_wire;
wire [ number_of_clocks -1 :0] locked_wire;
wire [ number_of_clocks -1 :0] outclk_wire;
wire [ number_of_clocks -1 :0] divclk_wire;
wire feedback_clk;
wire lvds_fbclk;
wire fb_clkin;
wire fb_out_clk;
wire fb_obuf_clk;
wire [1:0] clkbad_wire;
wire activeclk_wire;
wire [7:0] phout_wire;
wire [ number_of_clocks -1 : 0] cascade_out_wire;
wire [4:0] cntsel_temp /*synthesis keep*/; 	// Need this to prevent input port from synthesized away.
wire [4:0] cntsel_int ;  					// For DPS-only mode, we want lcells in the IP for counter rotation
wire gnd /* synthesis keep*/;

//unused wire to eliminate 'too few port' errors
wire wire_to_nowhere;
//wire_to_nowhere_64: 
//64 bit wires, 8 unused inputs to the altera_pll...
//'number of clocks' uses in 1 block...
//1 use in another block (note that the two blocks are mutually exclusive
wire [63:0] wire_to_nowhere_64 [ number_of_clocks :  0][7:0];

// synthesis translate off
integer pll_frequency_int;
wire pll_clock;

// ui
reg different_format_error;


// output clocks
reg  [8*MAX_STRING_LENGTH:1] output_clock_frequency_parameter[number_of_clocks -1 :0];

// precision control
reg ref_specified_as_period;
reg out_specified_as_period;
integer output_clock_frequency_value[ number_of_clocks -1 :0];

integer counter_N;
integer counter_M;
integer counter_C[ number_of_clocks -1 :0];
integer count_up_to_C[ number_of_clocks -1 :0];

integer common_freq;
integer current_lcm;

integer ii;

reg [8*MAX_STRING_LENGTH:1] phase_shift_parameter[MAX_NUMBER_OF_CLOCKS-1:0];
real phase_shift_value[MAX_NUMBER_OF_CLOCKS-1:0];

integer duty_cycle_parameter[MAX_NUMBER_OF_CLOCKS-1:0];

real duty_cycle_hi[MAX_NUMBER_OF_CLOCKS-1:0];
real tmp_period;

// outputs
reg [ number_of_clocks -1 :0] outclk_reg;
reg [ number_of_clocks -1 :0] outclk_reg_phase;

integer adjusted_pll_freq_param;

// synthesis translate on



// synthesis translate off
initial
begin
    if ( pll_frequency_parameter == -1 )
    begin
        // call again to get the error msg
		pll_frequency_int		= compute_pll_frequency
                                              (
                                                      output_clock_frequency0,
                                                    output_clock_frequency1,
                                                    output_clock_frequency2,
                                                    output_clock_frequency3,
                                                    output_clock_frequency4,
                                                    output_clock_frequency5,
                                                    output_clock_frequency6,
                                                    output_clock_frequency7,
                                                    output_clock_frequency8,
                                                    output_clock_frequency9,
                                                    output_clock_frequency10,
                                                    output_clock_frequency11,
                                                    output_clock_frequency12,
                                                    output_clock_frequency13,
                                                    output_clock_frequency14,
                                                    output_clock_frequency15,
                                                    output_clock_frequency16,
                                                    output_clock_frequency17,
                                                    number_of_clocks,
													reference_clock_frequency,
													using_khz
                                              );
        $finish;
    end



    // copy all parameters to arrays
    output_clock_frequency_parameter[0] = output_clock_frequency0;
    output_clock_frequency_parameter[1] = output_clock_frequency1;
    output_clock_frequency_parameter[2] = output_clock_frequency2;
    output_clock_frequency_parameter[3] = output_clock_frequency3;
    output_clock_frequency_parameter[4] = output_clock_frequency4;
    output_clock_frequency_parameter[5] = output_clock_frequency5;
    output_clock_frequency_parameter[6] = output_clock_frequency6;
    output_clock_frequency_parameter[7] = output_clock_frequency7;
    output_clock_frequency_parameter[8] = output_clock_frequency8;
    output_clock_frequency_parameter[9] = output_clock_frequency9;
    output_clock_frequency_parameter[10] = output_clock_frequency10;
    output_clock_frequency_parameter[11] = output_clock_frequency11;
    output_clock_frequency_parameter[12] = output_clock_frequency12;
    output_clock_frequency_parameter[13] = output_clock_frequency13;
    output_clock_frequency_parameter[14] = output_clock_frequency14;
    output_clock_frequency_parameter[15] = output_clock_frequency15;
    output_clock_frequency_parameter[16] = output_clock_frequency16;
    output_clock_frequency_parameter[17] = output_clock_frequency17;
    

    phase_shift_parameter[0] = phase_shift0;
    phase_shift_parameter[1] = phase_shift1;
    phase_shift_parameter[2] = phase_shift2;
    phase_shift_parameter[3] = phase_shift3;
    phase_shift_parameter[4] = phase_shift4;
    phase_shift_parameter[5] = phase_shift5;
    phase_shift_parameter[6] = phase_shift6;
    phase_shift_parameter[7] = phase_shift7;
    phase_shift_parameter[8] = phase_shift8;
    phase_shift_parameter[9] = phase_shift9;
    phase_shift_parameter[10] = phase_shift10;
    phase_shift_parameter[11] = phase_shift11;
    phase_shift_parameter[12] = phase_shift12;
    phase_shift_parameter[13] = phase_shift13;
    phase_shift_parameter[14] = phase_shift14;
    phase_shift_parameter[15] = phase_shift15;
    phase_shift_parameter[16] = phase_shift16;
    phase_shift_parameter[17] = phase_shift17;


    duty_cycle_parameter[0] = duty_cycle0;
    duty_cycle_parameter[1] = duty_cycle1;
    duty_cycle_parameter[2] = duty_cycle2;
    duty_cycle_parameter[3] = duty_cycle3;
    duty_cycle_parameter[4] = duty_cycle4;
    duty_cycle_parameter[5] = duty_cycle5;
    duty_cycle_parameter[6] = duty_cycle6;
    duty_cycle_parameter[7] = duty_cycle7;
    duty_cycle_parameter[8] = duty_cycle8;
    duty_cycle_parameter[9] = duty_cycle9;
    duty_cycle_parameter[10] = duty_cycle10;
    duty_cycle_parameter[11] = duty_cycle11;
    duty_cycle_parameter[12] = duty_cycle12;
    duty_cycle_parameter[13] = duty_cycle13;
    duty_cycle_parameter[14] = duty_cycle14;
    duty_cycle_parameter[15] = duty_cycle15;
    duty_cycle_parameter[16] = duty_cycle16;
    duty_cycle_parameter[17] = duty_cycle17;


    // we need to have both frequency and period
    if ( is_period(reference_clock_frequency) )
        ref_specified_as_period = 1;
    else
        ref_specified_as_period = 0;

    // Any input parameter format mismatch is already taken care of, so we only need to look at the
    // first parameter
    if ( is_period(output_clock_frequency_parameter[0]) )
        out_specified_as_period = 1;    
    else
        out_specified_as_period = 0;

        
	adjusted_pll_freq_param = (using_khz) ? (pll_frequency_parameter*1000) : pll_frequency_parameter;


    if (out_specified_as_period == 0 && ref_specified_as_period == 0 )
    begin
        for ( ii = 0; ii < number_of_clocks; ii = ii + 1 )
        begin
            output_clock_frequency_value[ii] = get_frequency_value(output_clock_frequency_parameter[ii]);
            counter_C[ii] =  rounded_division(adjusted_pll_freq_param,output_clock_frequency_value[ii]);
        end
    end
    else if (out_specified_as_period == 0)
    begin
        $display("Error: Output clock frequency is specified in Hz and reference clock in secs");
        $display("Please specify both either as frequencies or as time periods.");
        $finish;
    end

    for ( ii = 0; ii < number_of_clocks; ii = ii + 1 )
    begin
        count_up_to_C[ii] = 0;
        outclk_reg[ii] = 0;
    end


    for ( ii = 0; ii < MAX_NUMBER_OF_CLOCKS && ii < number_of_clocks; ii = ii + 1)
        phase_shift_value[ii] = get_phase_shift_value(phase_shift_parameter[ii],output_clock_frequency_parameter[ii]);


    for ( ii = 0; ii < MAX_NUMBER_OF_CLOCKS && ii < number_of_clocks; ii = ii + 1)
    begin
        // this is an inaccurate computation that will be used only if the duty cycle is not 50
        tmp_period = get_real_value(output_clock_frequency_parameter[ii]);
        duty_cycle_hi[ii] = duty_cycle_parameter[ii]*tmp_period / 100;
        if ( duty_cycle_parameter[ii] != 50 && counter_C[ii] != 1 )
        begin
            counter_C[ii] = 2 * counter_C[ii];
        end
    end

end

// synthesis translate on
assign reconfig_from_pll_wire[63:18] = 0;

generate 
    
    if (pll_type != "General")
    begin
        `define RECONFIGURABLE
        if (pll_subtype == "DPS" || pll_subtype == "General") 
        begin
            //don't assing phase done and locked zeros
            assign reconfig_from_pll_wire[15:0]= 0;
        end
    end
        
endgenerate 



generate
genvar i;  
    if (pll_type == "General" 
    // synthesis translate off
    && use_old_model == 1
    // synthesis translate on
    )
    for (i=0; i<=number_of_clocks-1; i = i +1)
    begin : general
    generic_pll #(
                .reference_clock_frequency(reference_clock_frequency),
				.fractional_vco_multiplier(fractional_vco_multiplier),
                .sim_additional_refclk_cycles_to_lock(sim_additional_refclk_cycles_to_lock),
                .output_clock_frequency((i == 0) ? output_clock_frequency0 : 
                                    (i == 1) ? output_clock_frequency1 :
                                    (i == 2) ? output_clock_frequency2 :
                                    (i == 3) ? output_clock_frequency3 :
                                    (i == 4) ? output_clock_frequency4 :
                                    (i == 5) ? output_clock_frequency5 :
                                    (i == 6) ? output_clock_frequency6 :
                                    (i == 7) ? output_clock_frequency7 :
                                    (i == 8) ? output_clock_frequency8 :
                                    (i == 9) ? output_clock_frequency9 :
                                    (i == 10) ? output_clock_frequency10 :
                                    (i == 11) ? output_clock_frequency11 :
                                    (i == 12) ? output_clock_frequency12 :
                                    (i == 13) ? output_clock_frequency13 :
                                    (i == 14) ? output_clock_frequency14 :
                                    (i == 15) ? output_clock_frequency15 :
                                    (i == 16) ? output_clock_frequency16 : output_clock_frequency17), 
                .duty_cycle((i == 0) ? duty_cycle0 : 
                        (i == 1) ? duty_cycle1 :
                        (i == 2) ? duty_cycle2 :
                        (i == 3) ? duty_cycle3 :
                        (i == 4) ? duty_cycle4 :
                        (i == 5) ? duty_cycle5 :
                        (i == 6) ? duty_cycle6 :
                        (i == 7) ? duty_cycle7 :
                        (i == 8) ? duty_cycle8 :
                        (i == 9) ? duty_cycle9 :
                        (i == 10) ? duty_cycle10 :
                        (i == 11) ? duty_cycle11 :
                        (i == 12) ? duty_cycle12 :
                        (i == 13) ? duty_cycle13 :
                        (i == 14) ? duty_cycle14 :
                        (i == 15) ? duty_cycle15 :
                        (i == 16) ? duty_cycle16 : duty_cycle17), 
                .clock_name( (i == 0) ? clock_name_0 :
                             (i == 1) ? clock_name_1 :
                             (i == 2) ? clock_name_2 :
                             (i == 3) ? clock_name_3 :
                             (i == 4) ? clock_name_4 :
                             (i == 5) ? clock_name_5 :
                             (i == 6) ? clock_name_6 :
                             (i == 7) ? clock_name_7 :
                             (i == 8) ? clock_name_8 : "" ),
                .clock_name_global( (i == 0) ? clock_name_global_0 :
                                    (i == 1) ? clock_name_global_1 :
                                    (i == 2) ? clock_name_global_2 :
                                    (i == 3) ? clock_name_global_3 :
                                    (i == 4) ? clock_name_global_4 :
                                    (i == 5) ? clock_name_global_5 :
                                    (i == 6) ? clock_name_global_6 :
                                    (i == 7) ? clock_name_global_7 :
                                    (i == 8) ? clock_name_global_8 : "false" ),
						.phase_shift((i == 0) ? phase_shift0 : 
                            (i == 1) ? phase_shift1 :
                            (i == 2) ? phase_shift2 :
                            (i == 3) ? phase_shift3 :
                            (i == 4) ? phase_shift4 :
                            (i == 5) ? phase_shift5 :
                            (i == 6) ? phase_shift6 :
                            (i == 7) ? phase_shift7 :
                            (i == 8) ? phase_shift8 :
                            (i == 9) ? phase_shift9 :
                            (i == 10) ? phase_shift10 :
                            (i == 11) ? phase_shift11 :
                            (i == 12) ? phase_shift12 :
                            (i == 13) ? phase_shift13 :
                            (i == 14) ? phase_shift14 :
                            (i == 15) ? phase_shift15 :
                            (i == 16) ? phase_shift16 : phase_shift17)
    ) gpll (
                     .refclk(refclk),
                     .fbclk((operation_mode == "external feedback" || operation_mode == "external") ? fb_clkin : (operation_mode == "zero delay buffer" || operation_mode == "zdb") ? fb_out_clk : fboutclk_wire[0]),
                     .rst(rst),
                     .fboutclk(fboutclk_wire[i]),
                     .outclk(outclk_wire[i]),
                     .locked(locked_wire[i]),
		     //unused ports
		     .writerefclkdata(wire_to_nowhere_64[i][0]),
		     .writeoutclkdata(wire_to_nowhere_64[i][1]),
		     .writephaseshiftdata(wire_to_nowhere_64[i][2]),
		     .readrefclkdata(wire_to_nowhere_64[i][3]),
		     .readoutclkdata(wire_to_nowhere_64[i][4]),
		     .readphaseshiftdata(wire_to_nowhere_64[i][6]),
		     .readdutycycledata(wire_to_nowhere_64[i][7])
                 );
    end  

    `ifdef RECONFIGURABLE
    else 
    begin
        if (pll_type == "Arria 10")
            dps_pulse_gen dps_pulse_gen_inst(
                .clk           ( (pll_subtype == "DPS") ? scanclk : reconfig_to_pll[0] ),
                .rst           ( rst                                                   ),
                .user_phase_en ( (pll_subtype == "DPS") ? phase_en:reconfig_to_pll[29] ),
                .phase_en      ( final_phase_en                                        )
            );
        else
        begin
            dps_extra_kick dps_extra_inst(
                .clk(pll_subtype != "General" ? ((pll_subtype == "DPS") ? scanclk : reconfig_to_pll[0]) : 1'b0),
                .reset(rst),
                .phase_done(reconfig_from_pll_wire[17]),
                .usr_phase_en(pll_subtype != "General" ? ((pll_subtype == "ReconfDPS") || (pll_subtype == "DPS") ? phase_en:reconfig_to_pll[30]) : 1'b0),
                .phase_en(final_phase_en));

            dprio_init dprio_init_inst (
                .clk(scanclk),
                .reset_n(~rst),
                .dprio_address(dps_address),
                .dprio_byteen(dps_byteen),
                .dprio_write(dps_write),
                .dprio_writedata(dps_writedata),

                .atpgmode(dps_atpgmode),
                .mdio_dis(dps_mdio_dis),
                .scanen(dps_scanen),
                .ser_shift_load(dps_ser_shift_load),
                //unused wire to eliminate 'too few port' warnings
                .dprio_init_done(wire_to_nowhere));
        end

        if (pll_type == "Stratix V")
        begin 
            assign cntsel_temp = cntsel;
            assign gnd = 1'b0;

            //cnt select luts (5)
            altera_pll_dps_lcell_comb lcell_cntsel_int_0 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[0]));
            defparam lcell_cntsel_int_0.lut_mask = 64'hAAAAAAAAAAAAAAAA;
            defparam lcell_cntsel_int_0.dont_touch = "on";
            defparam lcell_cntsel_int_0.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_1 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[1]));
            defparam lcell_cntsel_int_1.lut_mask = 64'hCCCCCCCCCCCCCCCC;
            defparam lcell_cntsel_int_1.dont_touch = "on";
            defparam lcell_cntsel_int_1.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_2 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[2]));
            defparam lcell_cntsel_int_2.lut_mask = 64'hF0F0F0F0F0F0F0F0;
            defparam lcell_cntsel_int_2.dont_touch = "on";
            defparam lcell_cntsel_int_2.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_3 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[3]));
            defparam lcell_cntsel_int_3.lut_mask = 64'hFF00FF00FF00FF00;
            defparam lcell_cntsel_int_3.dont_touch = "on";
            defparam lcell_cntsel_int_3.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_4 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[4]));
            defparam lcell_cntsel_int_4.lut_mask = 64'hFFFF0000FFFF0000;
            defparam lcell_cntsel_int_4.dont_touch = "on";
            defparam lcell_cntsel_int_4.family = pll_type;
   
            altera_stratixv_pll #(
                .number_of_fplls(1),
                .pll_vco_div_0(pll_vco_div),
				.pll_slf_rst_0(pll_slf_rst),
                .reference_clock_frequency_0 (reference_clock_frequency),
                .pll_output_clock_frequency_0 (pll_output_clk_frequency),
                .dpa_output_clock_frequency_0 (pll_output_clk_frequency),
                .enable_output_counter_0 ((number_of_clocks >= 1) ? "true" : "false"),
                .enable_output_counter_1 ((number_of_clocks >= 2) ? "true" : "false"),
                .enable_output_counter_2 ((number_of_clocks >= 3) ? "true" : "false"),
                .enable_output_counter_3 ((number_of_clocks >= 4) ? "true" : "false"),
                .enable_output_counter_4 ((number_of_clocks >= 5) ? "true" : "false"),
                .enable_output_counter_5 ((number_of_clocks >= 6) ? "true" : "false"),
                .enable_output_counter_6 ((number_of_clocks >= 7) ? "true" : "false"),
                .enable_output_counter_7 ((number_of_clocks >= 8) ? "true" : "false"),
                .enable_output_counter_8 ((number_of_clocks >= 9) ? "true" : "false"),
                .enable_output_counter_9 ((number_of_clocks >= 10) ? "true" : "false"),
                .enable_output_counter_10 ((number_of_clocks >= 11) ? "true" : "false"),
                .enable_output_counter_11 ((number_of_clocks >= 12) ? "true" : "false"),
                .enable_output_counter_12 ((number_of_clocks >= 13) ? "true" : "false"),
                .enable_output_counter_13 ((number_of_clocks >= 14) ? "true" : "false"),
                .enable_output_counter_14 ((number_of_clocks >= 15) ? "true" : "false"),
                .enable_output_counter_15 ((number_of_clocks >= 16) ? "true" : "false"),
                .enable_output_counter_16 ((number_of_clocks >= 17) ? "true" : "false"),
                .enable_output_counter_17 ((number_of_clocks >= 18) ? "true" : "false"),
                .number_of_extclks ((operation_mode == "external feedback" || operation_mode == "zero delay buffer") ? 1 : 0),
                .enable_extclk_output_0 ((operation_mode == "external feedback" || operation_mode == "zero delay buffer") ? "true" : "false"),
                .number_of_counters(number_of_clocks),
                .pll_dsm_out_sel_0((fractional_vco_multiplier == "true") ? pll_dsm_out_sel : "disable"),
                .pll_dsm_dither_0((fractional_vco_multiplier == "true") ? "disable" : "disable"),
                .pll_cp_current_0 (pll_cp_current),
                .pll_fractional_division_0 (pll_fractional_division),
                .pll_fractional_carry_out_0 (pll_fractional_cout),
                .pll_bwctrl_0 (pll_bwctrl),
                .mimic_fbclk_type_0 (mimic_fbclk_type),
                .pll_fbclk_mux_1_0 (pll_fbclk_mux_1),
                .pll_fbclk_mux_2_0 (pll_fbclk_mux_2),
                .pll_m_cnt_in_src_0 (pll_m_cnt_in_src),
                .pll_m_cnt_hi_div_0(m_cnt_hi_div),
                .pll_m_cnt_lo_div_0 (m_cnt_lo_div),
                .pll_m_cnt_bypass_en_0 (m_cnt_bypass_en),
                .pll_m_cnt_odd_div_duty_en_0 (m_cnt_odd_div_duty_en),
                .pll_n_cnt_hi_div_0 (n_cnt_hi_div),
                .pll_n_cnt_lo_div_0 (n_cnt_lo_div),
                .pll_n_cnt_bypass_en_0 (n_cnt_bypass_en),
                .pll_n_cnt_odd_div_duty_en_0 (n_cnt_odd_div_duty_en),
                .output_clock_frequency_0 (output_clock_frequency0),
				.phase_shift_0(phase_shift0),
                .dprio0_cnt_hi_div_0 (c_cnt_hi_div0), 
                .dprio0_cnt_lo_div_0 (c_cnt_lo_div0),
                .dprio0_cnt_bypass_en_0 (c_cnt_bypass_en0),
                .dprio0_cnt_odd_div_even_duty_en_0 (c_cnt_odd_div_duty_en0),
                .c_cnt_prst_0 (c_cnt_prst0),
                .c_cnt_ph_mux_prst_0 (c_cnt_ph_mux_prst0),
                .output_clock_frequency_1 (output_clock_frequency1),
				.phase_shift_1(phase_shift1),
                .dprio0_cnt_hi_div_1 (c_cnt_hi_div1), 
                .dprio0_cnt_lo_div_1 (c_cnt_lo_div1),
                .dprio0_cnt_bypass_en_1 (c_cnt_bypass_en1),
                .dprio0_cnt_odd_div_even_duty_en_1 (c_cnt_odd_div_duty_en1),
                .c_cnt_prst_1 (c_cnt_prst1),
                .c_cnt_ph_mux_prst_1 (c_cnt_ph_mux_prst1),
                .output_clock_frequency_2 (output_clock_frequency2),
				.phase_shift_2(phase_shift2),
                .dprio0_cnt_hi_div_2 (c_cnt_hi_div2), 
                .dprio0_cnt_lo_div_2 (c_cnt_lo_div2),
                .dprio0_cnt_bypass_en_2 (c_cnt_bypass_en2),
                .dprio0_cnt_odd_div_even_duty_en_2 (c_cnt_odd_div_duty_en2),
                .c_cnt_prst_2 (c_cnt_prst2),
                .c_cnt_ph_mux_prst_2 (c_cnt_ph_mux_prst2),
                .output_clock_frequency_3 (output_clock_frequency3),
				.phase_shift_3(phase_shift3),
                .dprio0_cnt_hi_div_3 (c_cnt_hi_div3), 
                .dprio0_cnt_lo_div_3 (c_cnt_lo_div3),
                .dprio0_cnt_bypass_en_3 (c_cnt_bypass_en3),
                .dprio0_cnt_odd_div_even_duty_en_3 (c_cnt_odd_div_duty_en3),
                .c_cnt_prst_3 (c_cnt_prst3),
                .c_cnt_ph_mux_prst_3 (c_cnt_ph_mux_prst3),
                .output_clock_frequency_4 (output_clock_frequency4),
				.phase_shift_4(phase_shift4),
                .dprio0_cnt_hi_div_4 (c_cnt_hi_div4), 
                .dprio0_cnt_lo_div_4 (c_cnt_lo_div4),
                .dprio0_cnt_bypass_en_4 (c_cnt_bypass_en4),
                .dprio0_cnt_odd_div_even_duty_en_4 (c_cnt_odd_div_duty_en4),
                .c_cnt_prst_4 (c_cnt_prst4),
                .c_cnt_ph_mux_prst_4 (c_cnt_ph_mux_prst4),
                .output_clock_frequency_5 (output_clock_frequency5),
				.phase_shift_5(phase_shift5),
                .dprio0_cnt_hi_div_5 (c_cnt_hi_div5), 
                .dprio0_cnt_lo_div_5 (c_cnt_lo_div5),
                .dprio0_cnt_bypass_en_5 (c_cnt_bypass_en5),
                .dprio0_cnt_odd_div_even_duty_en_5 (c_cnt_odd_div_duty_en5),
                .c_cnt_prst_5 (c_cnt_prst5),
                .c_cnt_ph_mux_prst_5 (c_cnt_ph_mux_prst5),
                .output_clock_frequency_6 (output_clock_frequency6),
				.phase_shift_6(phase_shift6),
                .dprio0_cnt_hi_div_6 (c_cnt_hi_div6), 
                .dprio0_cnt_lo_div_6 (c_cnt_lo_div6),
                .dprio0_cnt_bypass_en_6 (c_cnt_bypass_en6),
                .dprio0_cnt_odd_div_even_duty_en_6 (c_cnt_odd_div_duty_en6),
                .c_cnt_prst_6 (c_cnt_prst6),
                .c_cnt_ph_mux_prst_6 (c_cnt_ph_mux_prst6),
                .output_clock_frequency_7 (output_clock_frequency7),
				.phase_shift_7(phase_shift7),
                .dprio0_cnt_hi_div_7 (c_cnt_hi_div7), 
                .dprio0_cnt_lo_div_7 (c_cnt_lo_div7),
                .dprio0_cnt_bypass_en_7 (c_cnt_bypass_en7),
                .dprio0_cnt_odd_div_even_duty_en_7 (c_cnt_odd_div_duty_en7),
                .c_cnt_prst_7 (c_cnt_prst7),
                .c_cnt_ph_mux_prst_7 (c_cnt_ph_mux_prst7),
                .output_clock_frequency_8 (output_clock_frequency8),
				.phase_shift_8(phase_shift8),
                .dprio0_cnt_hi_div_8 (c_cnt_hi_div8), 
                .dprio0_cnt_lo_div_8 (c_cnt_lo_div8),
                .dprio0_cnt_bypass_en_8 (c_cnt_bypass_en8),
                .dprio0_cnt_odd_div_even_duty_en_8 (c_cnt_odd_div_duty_en8),
                .c_cnt_prst_8 (c_cnt_prst8),
                .c_cnt_ph_mux_prst_8 (c_cnt_ph_mux_prst8),
                .output_clock_frequency_9 (output_clock_frequency9),
				.phase_shift_9(phase_shift9),
                .dprio0_cnt_hi_div_9 (c_cnt_hi_div9), 
                .dprio0_cnt_lo_div_9 (c_cnt_lo_div9),
                .dprio0_cnt_bypass_en_9 (c_cnt_bypass_en9),
                .dprio0_cnt_odd_div_even_duty_en_9 (c_cnt_odd_div_duty_en9),
                .c_cnt_prst_9 (c_cnt_prst9),
                .c_cnt_ph_mux_prst_9 (c_cnt_ph_mux_prst9),
                .output_clock_frequency_10 (output_clock_frequency10),
				.phase_shift_10(phase_shift10),
                .dprio0_cnt_hi_div_10 (c_cnt_hi_div10), 
                .dprio0_cnt_lo_div_10 (c_cnt_lo_div10),
                .dprio0_cnt_bypass_en_10 (c_cnt_bypass_en10),
                .dprio0_cnt_odd_div_even_duty_en_10 (c_cnt_odd_div_duty_en10),
                .c_cnt_prst_10 (c_cnt_prst10),
                .c_cnt_ph_mux_prst_10 (c_cnt_ph_mux_prst10),
                .output_clock_frequency_11 (output_clock_frequency11),
				.phase_shift_11(phase_shift11),
                .dprio0_cnt_hi_div_11 (c_cnt_hi_div11), 
                .dprio0_cnt_lo_div_11 (c_cnt_lo_div11),
                .dprio0_cnt_bypass_en_11 (c_cnt_bypass_en11),
                .dprio0_cnt_odd_div_even_duty_en_11 (c_cnt_odd_div_duty_en11),
                .c_cnt_prst_11 (c_cnt_prst11),
                .c_cnt_ph_mux_prst_11 (c_cnt_ph_mux_prst11),
                .output_clock_frequency_12 (output_clock_frequency12),
				.phase_shift_12(phase_shift12),
                .dprio0_cnt_hi_div_12 (c_cnt_hi_div12), 
                .dprio0_cnt_lo_div_12 (c_cnt_lo_div12),
                .dprio0_cnt_bypass_en_12 (c_cnt_bypass_en12),
                .dprio0_cnt_odd_div_even_duty_en_12 (c_cnt_odd_div_duty_en12),
                .c_cnt_prst_12 (c_cnt_prst12),
                .c_cnt_ph_mux_prst_12 (c_cnt_ph_mux_prst12),
                .output_clock_frequency_13 (output_clock_frequency13),
				.phase_shift_13(phase_shift13),
                .dprio0_cnt_hi_div_13 (c_cnt_hi_div13), 
                .dprio0_cnt_lo_div_13 (c_cnt_lo_div13),
                .dprio0_cnt_bypass_en_13 (c_cnt_bypass_en13),
                .dprio0_cnt_odd_div_even_duty_en_13 (c_cnt_odd_div_duty_en13),
                .c_cnt_prst_13 (c_cnt_prst13),
                .c_cnt_ph_mux_prst_13 (c_cnt_ph_mux_prst13),
                .output_clock_frequency_14 (output_clock_frequency14),
				.phase_shift_14(phase_shift14),
                .dprio0_cnt_hi_div_14 (c_cnt_hi_div14), 
                .dprio0_cnt_lo_div_14 (c_cnt_lo_div14),
                .dprio0_cnt_bypass_en_14 (c_cnt_bypass_en14),
                .dprio0_cnt_odd_div_even_duty_en_14 (c_cnt_odd_div_duty_en14),
                .c_cnt_prst_14 (c_cnt_prst14),
                .c_cnt_ph_mux_prst_14 (c_cnt_ph_mux_prst14),
                .output_clock_frequency_15 (output_clock_frequency15),
				.phase_shift_15(phase_shift15),
                .dprio0_cnt_hi_div_15 (c_cnt_hi_div15), 
                .dprio0_cnt_lo_div_15 (c_cnt_lo_div15),
                .dprio0_cnt_bypass_en_15 (c_cnt_bypass_en15),
                .dprio0_cnt_odd_div_even_duty_en_15 (c_cnt_odd_div_duty_en15),
                .c_cnt_prst_15 (c_cnt_prst15),
                .c_cnt_ph_mux_prst_15 (c_cnt_ph_mux_prst15),
                .output_clock_frequency_16 (output_clock_frequency16),
				.phase_shift_16(phase_shift16),
                .dprio0_cnt_hi_div_16 (c_cnt_hi_div16), 
                .dprio0_cnt_lo_div_16 (c_cnt_lo_div16),
                .dprio0_cnt_bypass_en_16 (c_cnt_bypass_en16),
                .dprio0_cnt_odd_div_even_duty_en_16 (c_cnt_odd_div_duty_en16),
                .c_cnt_prst_16 (c_cnt_prst16),
                .c_cnt_ph_mux_prst_16 (c_cnt_ph_mux_prst16),
                .output_clock_frequency_17 (output_clock_frequency17),
				.phase_shift_17(phase_shift17),
                .dprio0_cnt_hi_div_17 (c_cnt_hi_div17), 
                .dprio0_cnt_lo_div_17 (c_cnt_lo_div17),
                .dprio0_cnt_bypass_en_17 (c_cnt_bypass_en17),
                .dprio0_cnt_odd_div_even_duty_en_17 (c_cnt_odd_div_duty_en17),
                .c_cnt_prst_17 (c_cnt_prst17),
                .c_cnt_ph_mux_prst_17 (c_cnt_ph_mux_prst17),
				//duty cycle params
				.duty_cycle_0(duty_cycle0),
				.duty_cycle_1(duty_cycle1),
				.duty_cycle_2(duty_cycle2),
				.duty_cycle_3(duty_cycle3),
				.duty_cycle_4(duty_cycle4),
				.duty_cycle_5(duty_cycle5),
				.duty_cycle_6(duty_cycle6),
				.duty_cycle_7(duty_cycle7),
				.duty_cycle_8(duty_cycle8),
				.duty_cycle_9(duty_cycle9),
				.duty_cycle_10(duty_cycle10),
				.duty_cycle_11(duty_cycle11),
				.duty_cycle_12(duty_cycle12),
				.duty_cycle_13(duty_cycle13),
				.duty_cycle_14(duty_cycle14),
				.duty_cycle_15(duty_cycle15),
				.duty_cycle_16(duty_cycle16),
				.duty_cycle_17(duty_cycle17),
                //output counter cascading params
                .c_cnt_in_src_0 (c_cnt_in_src0),
                .c_cnt_in_src_1 (c_cnt_in_src1),
                .c_cnt_in_src_2 (c_cnt_in_src2),
                .c_cnt_in_src_3 (c_cnt_in_src3),
                .c_cnt_in_src_4 (c_cnt_in_src4),
                .c_cnt_in_src_5 (c_cnt_in_src5),
                .c_cnt_in_src_6 (c_cnt_in_src6),
                .c_cnt_in_src_7 (c_cnt_in_src7),
                .c_cnt_in_src_8 (c_cnt_in_src8),
                .c_cnt_in_src_9 (c_cnt_in_src9),
                .c_cnt_in_src_10 (c_cnt_in_src10),
                .c_cnt_in_src_11 (c_cnt_in_src11),
                .c_cnt_in_src_12 (c_cnt_in_src12),
                .c_cnt_in_src_13 (c_cnt_in_src13),
                .c_cnt_in_src_14 (c_cnt_in_src14),
                .c_cnt_in_src_15 (c_cnt_in_src15),
                .c_cnt_in_src_16 (c_cnt_in_src16),
                .c_cnt_in_src_17 (c_cnt_in_src17),
                //refclk select params
                .pll_auto_clk_sw_en_0 (pll_auto_clk_sw_en),
                .pll_clk_loss_sw_en_0 (pll_clk_loss_sw_en),
                .pll_clk_sw_dly_0    (pll_clk_sw_dly),
                .pll_clkin_0_src_0   (pll_clkin_0_src),
                .pll_clkin_1_src_0   (pll_clkin_1_src),
                .pll_manu_clk_sw_en_0  (pll_manu_clk_sw_en),
				.pll_vcoph_div_0 (pll_vcoph_div)
        )

             stratixv_pll (
                // stratixv_pll_dpa_output pins
                .phout_0(phout_wire),
                .phout_1(),
                
                // stratixv_pll_refclk_select pins
                .adjpllin(adjpllin),    
                .cclk(cclk),
                .coreclkin(),
                .extswitch(extswitch),
                .iqtxrxclkin(),
                .plliqclkin(),
                .rxiqclkin(),
                .clkin({2'b0,refclk1, refclk}),
                .refiqclk_0(),
                .refiqclk_1(),
                .clk0bad(clkbad_wire[0]),
                .clk1bad(clkbad_wire[1]),
                .pllclksel(activeclk_wire),

                // stratixv_pll_reconfig pins
                .atpgmode(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_atpgmode : reconfig_to_pll[38]) : 1'b0),
                .clk(pll_subtype != "General" ? ((pll_subtype == "DPS") ? scanclk : reconfig_to_pll[0]) : 1'b0),
                .fpllcsrtest(reconfig_to_pll[38]),
                .iocsrclkin(),
                .iocsrdatain(),
                .iocsren(),
                .iocsrrstn(),
                .mdiodis(pll_subtype != "General" ? ((pll_subtype == "DPS") ? 1'b1 : reconfig_to_pll[29]) : 1'b1),
                .phaseen(final_phase_en),
                .read(reconfig_to_pll[3]),
                .rstn(pll_subtype != "General" ? ((pll_subtype == "DPS") ? ~rst : reconfig_to_pll[1]): 1'b1),
                .scanen(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_scanen : reconfig_to_pll[37]) : 1'b0),
                .sershiftload(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_ser_shift_load : reconfig_to_pll[28]) : 1'b1),
                .shiftdonei(),
                .updn(pll_subtype != "General" ? ((pll_subtype == "ReconfDPS") || (pll_subtype == "DPS") ? updn:reconfig_to_pll[31]) : 1'b0),
                .write(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_write : reconfig_to_pll[2]) :1'b0),
                .addr_0(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_address : reconfig_to_pll[9:4]) :6'b000000),
                .addr_1(),
                .byteen_0(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_byteen : reconfig_to_pll[27:26]) :2'b00),
                .byteen_1(),
                .cntsel_0(pll_subtype != "General" ? ((pll_subtype == "ReconfDPS") || (pll_subtype == "DPS") ? cntsel_int:reconfig_to_pll[36:32]) : 5'b00000),
                .cntsel_1(),
                .din_0(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_writedata : reconfig_to_pll[25:10]) :16'h0000),
                .din_1(),
                .blockselect(),
                .iocsrdataout(),
                .iocsrenbuf(),
                .iocsrrstnbuf(),
                .phasedone(reconfig_from_pll_wire[17]),
                .dout_0(reconfig_from_pll_wire[15:0]),
                .dout_1(),
                .dprioout_0(),
                .dprioout_1(),
                
                // stratixv_fractional_pll pins
                .fbclkfpll(),
                .lvdfbin((operation_mode == "lvds") ? lvds_fbclk : 1'b0),
                .nresync(~rst),
                .pfden(1'b1),
                .shiften_fpll(),
                .zdb((operation_mode == "external feedback") ? fb_clkin : (operation_mode == "zero delay buffer") ? fb_out_clk : 1'b0),
                .fblvdsout(lvds_fbclk),
                .lock(reconfig_from_pll_wire[16]),
                .mcntout(),
                .plniotribuf(),

                // stratixv_pll_extclk_output pins
                .clken(),
                .extclk(fboutclk_wire[0]),

                // stratixv_pll_dll_output pins
                .dll_clkin(),
                .clkout(),

                // stratixv_pll_lvds_output pins
                .loaden(),
                .lvdsclk(),

                // stratixv_pll_output_counter pins
                .divclk(divclk_wire),
				.cascade_out(cascade_out_wire)
                );
                
                assign locked_wire[0] = reconfig_from_pll_wire[16]; 
                assign outclk_wire = divclk_wire;
            end
            else if (pll_type == "Arria V") 
            begin    
            assign cntsel_temp = cntsel;
            assign gnd = 1'b0;

            //cnt select luts (5)
            altera_pll_dps_lcell_comb lcell_cntsel_int_0 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[0]));
            defparam lcell_cntsel_int_0.lut_mask = 64'hAAAAAAAAAAAAAAAA;
            defparam lcell_cntsel_int_0.dont_touch = "on";
            defparam lcell_cntsel_int_0.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_1 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[1]));
            defparam lcell_cntsel_int_1.lut_mask = 64'hCCCCCCCCCCCCCCCC;
            defparam lcell_cntsel_int_1.dont_touch = "on";
            defparam lcell_cntsel_int_1.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_2 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[2]));
            defparam lcell_cntsel_int_2.lut_mask = 64'hF0F0F0F0F0F0F0F0;
            defparam lcell_cntsel_int_2.dont_touch = "on";
            defparam lcell_cntsel_int_2.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_3 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[3]));
            defparam lcell_cntsel_int_3.lut_mask = 64'hFF00FF00FF00FF00;
            defparam lcell_cntsel_int_3.dont_touch = "on";
            defparam lcell_cntsel_int_3.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_4 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[4]));
            defparam lcell_cntsel_int_4.lut_mask = 64'hFFFF0000FFFF0000;
            defparam lcell_cntsel_int_4.dont_touch = "on";
            defparam lcell_cntsel_int_4.family = pll_type;
   
         
            altera_arriav_pll #(
                .number_of_fplls(1),
                .pll_vco_div_0(pll_vco_div),
				.pll_slf_rst_0(pll_slf_rst),
                .reference_clock_frequency_0 (reference_clock_frequency),
                .pll_output_clock_frequency_0 (pll_output_clk_frequency),
                .dpa_output_clock_frequency_0 (pll_output_clk_frequency),
                .enable_output_counter_0 ((number_of_clocks >= 1) ? "true" : "false"),
                .enable_output_counter_1 ((number_of_clocks >= 2) ? "true" : "false"),
                .enable_output_counter_2 ((number_of_clocks >= 3) ? "true" : "false"),
                .enable_output_counter_3 ((number_of_clocks >= 4) ? "true" : "false"),
                .enable_output_counter_4 ((number_of_clocks >= 5) ? "true" : "false"),
                .enable_output_counter_5 ((number_of_clocks >= 6) ? "true" : "false"),
                .enable_output_counter_6 ((number_of_clocks >= 7) ? "true" : "false"),
                .enable_output_counter_7 ((number_of_clocks >= 8) ? "true" : "false"),
                .enable_output_counter_8 ((number_of_clocks >= 9) ? "true" : "false"),
                .enable_output_counter_9 ((number_of_clocks >= 10) ? "true" : "false"),
                .enable_output_counter_10 ((number_of_clocks >= 11) ? "true" : "false"),
                .enable_output_counter_11 ((number_of_clocks >= 12) ? "true" : "false"),
                .enable_output_counter_12 ((number_of_clocks >= 13) ? "true" : "false"),
                .enable_output_counter_13 ((number_of_clocks >= 14) ? "true" : "false"),
                .enable_output_counter_14 ((number_of_clocks >= 15) ? "true" : "false"),
                .enable_output_counter_15 ((number_of_clocks >= 16) ? "true" : "false"),
                .enable_output_counter_16 ((number_of_clocks >= 17) ? "true" : "false"),
                .enable_output_counter_17 ((number_of_clocks >= 18) ? "true" : "false"),
                .number_of_extclks ((operation_mode == "external feedback" || operation_mode == "zero delay buffer") ? 1 : 0),
                .enable_extclk_output_0 ((operation_mode == "external feedback" || operation_mode == "zero delay buffer") ? "true" : "false"),
                .number_of_counters(number_of_clocks),
                .pll_dsm_out_sel_0((fractional_vco_multiplier == "true") ? pll_dsm_out_sel : "disable"),
                .pll_dsm_dither_0((fractional_vco_multiplier == "true") ? "disable" : "disable"),
                .pll_cp_current_0 (pll_cp_current),
                .pll_fractional_division_0 (pll_fractional_division),
                .pll_fractional_carry_out_0 (pll_fractional_cout),
                .pll_bwctrl_0 (pll_bwctrl),
                .mimic_fbclk_type_0 (mimic_fbclk_type),
                .pll_fbclk_mux_1_0 (pll_fbclk_mux_1),
                .pll_fbclk_mux_2_0 (pll_fbclk_mux_2),
                .pll_m_cnt_in_src_0 (pll_m_cnt_in_src),
                .pll_m_cnt_hi_div_0(m_cnt_hi_div),
                .pll_m_cnt_lo_div_0 (m_cnt_lo_div),
                .pll_m_cnt_bypass_en_0 (m_cnt_bypass_en),
                .pll_m_cnt_odd_div_duty_en_0 (m_cnt_odd_div_duty_en),
                .pll_n_cnt_hi_div_0 (n_cnt_hi_div),
                .pll_n_cnt_lo_div_0 (n_cnt_lo_div),
                .pll_n_cnt_bypass_en_0 (n_cnt_bypass_en),
                .pll_n_cnt_odd_div_duty_en_0 (n_cnt_odd_div_duty_en),
                .output_clock_frequency_0 (output_clock_frequency0),
				.phase_shift_0(phase_shift0),
                .dprio0_cnt_hi_div_0 (c_cnt_hi_div0), 
                .dprio0_cnt_lo_div_0 (c_cnt_lo_div0),
                .dprio0_cnt_bypass_en_0 (c_cnt_bypass_en0),
                .dprio0_cnt_odd_div_even_duty_en_0 (c_cnt_odd_div_duty_en0),
                .c_cnt_prst_0 (c_cnt_prst0),
                .c_cnt_ph_mux_prst_0 (c_cnt_ph_mux_prst0),
                .output_clock_frequency_1 (output_clock_frequency1),
				.phase_shift_1(phase_shift1),
                .dprio0_cnt_hi_div_1 (c_cnt_hi_div1), 
                .dprio0_cnt_lo_div_1 (c_cnt_lo_div1),
                .dprio0_cnt_bypass_en_1 (c_cnt_bypass_en1),
                .dprio0_cnt_odd_div_even_duty_en_1 (c_cnt_odd_div_duty_en1),
                .c_cnt_prst_1 (c_cnt_prst1),
                .c_cnt_ph_mux_prst_1 (c_cnt_ph_mux_prst1),
                .output_clock_frequency_2 (output_clock_frequency2),
				.phase_shift_2(phase_shift2),
                .dprio0_cnt_hi_div_2 (c_cnt_hi_div2), 
                .dprio0_cnt_lo_div_2 (c_cnt_lo_div2),
                .dprio0_cnt_bypass_en_2 (c_cnt_bypass_en2),
                .dprio0_cnt_odd_div_even_duty_en_2 (c_cnt_odd_div_duty_en2),
                .c_cnt_prst_2 (c_cnt_prst2),
                .c_cnt_ph_mux_prst_2 (c_cnt_ph_mux_prst2),
                .output_clock_frequency_3 (output_clock_frequency3),
				.phase_shift_3(phase_shift3),
                .dprio0_cnt_hi_div_3 (c_cnt_hi_div3), 
                .dprio0_cnt_lo_div_3 (c_cnt_lo_div3),
                .dprio0_cnt_bypass_en_3 (c_cnt_bypass_en3),
                .dprio0_cnt_odd_div_even_duty_en_3 (c_cnt_odd_div_duty_en3),
                .c_cnt_prst_3 (c_cnt_prst3),
                .c_cnt_ph_mux_prst_3 (c_cnt_ph_mux_prst3),
                .output_clock_frequency_4 (output_clock_frequency4),
				.phase_shift_4(phase_shift4),
                .dprio0_cnt_hi_div_4 (c_cnt_hi_div4), 
                .dprio0_cnt_lo_div_4 (c_cnt_lo_div4),
                .dprio0_cnt_bypass_en_4 (c_cnt_bypass_en4),
                .dprio0_cnt_odd_div_even_duty_en_4 (c_cnt_odd_div_duty_en4),
                .c_cnt_prst_4 (c_cnt_prst4),
                .c_cnt_ph_mux_prst_4 (c_cnt_ph_mux_prst4),
                .output_clock_frequency_5 (output_clock_frequency5),
				.phase_shift_5(phase_shift5),
                .dprio0_cnt_hi_div_5 (c_cnt_hi_div5), 
                .dprio0_cnt_lo_div_5 (c_cnt_lo_div5),
                .dprio0_cnt_bypass_en_5 (c_cnt_bypass_en5),
                .dprio0_cnt_odd_div_even_duty_en_5 (c_cnt_odd_div_duty_en5),
                .c_cnt_prst_5 (c_cnt_prst5),
                .c_cnt_ph_mux_prst_5 (c_cnt_ph_mux_prst5),
                .output_clock_frequency_6 (output_clock_frequency6),
				.phase_shift_6(phase_shift6),
                .dprio0_cnt_hi_div_6 (c_cnt_hi_div6), 
                .dprio0_cnt_lo_div_6 (c_cnt_lo_div6),
                .dprio0_cnt_bypass_en_6 (c_cnt_bypass_en6),
                .dprio0_cnt_odd_div_even_duty_en_6 (c_cnt_odd_div_duty_en6),
                .c_cnt_prst_6 (c_cnt_prst6),
                .c_cnt_ph_mux_prst_6 (c_cnt_ph_mux_prst6),
                .output_clock_frequency_7 (output_clock_frequency7),
				.phase_shift_7(phase_shift7),
                .dprio0_cnt_hi_div_7 (c_cnt_hi_div7), 
                .dprio0_cnt_lo_div_7 (c_cnt_lo_div7),
                .dprio0_cnt_bypass_en_7 (c_cnt_bypass_en7),
                .dprio0_cnt_odd_div_even_duty_en_7 (c_cnt_odd_div_duty_en7),
                .c_cnt_prst_7 (c_cnt_prst7),
                .c_cnt_ph_mux_prst_7 (c_cnt_ph_mux_prst7),
                .output_clock_frequency_8 (output_clock_frequency8),
				.phase_shift_8(phase_shift8),
                .dprio0_cnt_hi_div_8 (c_cnt_hi_div8), 
                .dprio0_cnt_lo_div_8 (c_cnt_lo_div8),
                .dprio0_cnt_bypass_en_8 (c_cnt_bypass_en8),
                .dprio0_cnt_odd_div_even_duty_en_8 (c_cnt_odd_div_duty_en8),
                .c_cnt_prst_8 (c_cnt_prst8),
                .c_cnt_ph_mux_prst_8 (c_cnt_ph_mux_prst8),
                .output_clock_frequency_9 (output_clock_frequency9),
				.phase_shift_9(phase_shift9),
                .dprio0_cnt_hi_div_9 (c_cnt_hi_div9), 
                .dprio0_cnt_lo_div_9 (c_cnt_lo_div9),
                .dprio0_cnt_bypass_en_9 (c_cnt_bypass_en9),
                .dprio0_cnt_odd_div_even_duty_en_9 (c_cnt_odd_div_duty_en9),
                .c_cnt_prst_9 (c_cnt_prst9),
                .c_cnt_ph_mux_prst_9 (c_cnt_ph_mux_prst9),
                .output_clock_frequency_10 (output_clock_frequency10),
				.phase_shift_10(phase_shift10),
                .dprio0_cnt_hi_div_10 (c_cnt_hi_div10), 
                .dprio0_cnt_lo_div_10 (c_cnt_lo_div10),
                .dprio0_cnt_bypass_en_10 (c_cnt_bypass_en10),
                .dprio0_cnt_odd_div_even_duty_en_10 (c_cnt_odd_div_duty_en10),
                .c_cnt_prst_10 (c_cnt_prst10),
                .c_cnt_ph_mux_prst_10 (c_cnt_ph_mux_prst10),
                .output_clock_frequency_11 (output_clock_frequency11),
				.phase_shift_11(phase_shift11),
                .dprio0_cnt_hi_div_11 (c_cnt_hi_div11), 
                .dprio0_cnt_lo_div_11 (c_cnt_lo_div11),
                .dprio0_cnt_bypass_en_11 (c_cnt_bypass_en11),
                .dprio0_cnt_odd_div_even_duty_en_11 (c_cnt_odd_div_duty_en11),
                .c_cnt_prst_11 (c_cnt_prst11),
                .c_cnt_ph_mux_prst_11 (c_cnt_ph_mux_prst11),
                .output_clock_frequency_12 (output_clock_frequency12),
				.phase_shift_12(phase_shift12),
                .dprio0_cnt_hi_div_12 (c_cnt_hi_div12), 
                .dprio0_cnt_lo_div_12 (c_cnt_lo_div12),
                .dprio0_cnt_bypass_en_12 (c_cnt_bypass_en12),
                .dprio0_cnt_odd_div_even_duty_en_12 (c_cnt_odd_div_duty_en12),
                .c_cnt_prst_12 (c_cnt_prst12),
                .c_cnt_ph_mux_prst_12 (c_cnt_ph_mux_prst12),
                .output_clock_frequency_13 (output_clock_frequency13),
				.phase_shift_13(phase_shift13),
                .dprio0_cnt_hi_div_13 (c_cnt_hi_div13), 
                .dprio0_cnt_lo_div_13 (c_cnt_lo_div13),
                .dprio0_cnt_bypass_en_13 (c_cnt_bypass_en13),
                .dprio0_cnt_odd_div_even_duty_en_13 (c_cnt_odd_div_duty_en13),
                .c_cnt_prst_13 (c_cnt_prst13),
                .c_cnt_ph_mux_prst_13 (c_cnt_ph_mux_prst13),
                .output_clock_frequency_14 (output_clock_frequency14),
				.phase_shift_14(phase_shift14),
                .dprio0_cnt_hi_div_14 (c_cnt_hi_div14), 
                .dprio0_cnt_lo_div_14 (c_cnt_lo_div14),
                .dprio0_cnt_bypass_en_14 (c_cnt_bypass_en14),
                .dprio0_cnt_odd_div_even_duty_en_14 (c_cnt_odd_div_duty_en14),
                .c_cnt_prst_14 (c_cnt_prst14),
                .c_cnt_ph_mux_prst_14 (c_cnt_ph_mux_prst14),
                .output_clock_frequency_15 (output_clock_frequency15),
				.phase_shift_15(phase_shift15),
                .dprio0_cnt_hi_div_15 (c_cnt_hi_div15), 
                .dprio0_cnt_lo_div_15 (c_cnt_lo_div15),
                .dprio0_cnt_bypass_en_15 (c_cnt_bypass_en15),
                .dprio0_cnt_odd_div_even_duty_en_15 (c_cnt_odd_div_duty_en15),
                .c_cnt_prst_15 (c_cnt_prst15),
                .c_cnt_ph_mux_prst_15 (c_cnt_ph_mux_prst15),
                .output_clock_frequency_16 (output_clock_frequency16),
				.phase_shift_16(phase_shift16),
                .dprio0_cnt_hi_div_16 (c_cnt_hi_div16), 
                .dprio0_cnt_lo_div_16 (c_cnt_lo_div16),
                .dprio0_cnt_bypass_en_16 (c_cnt_bypass_en16),
                .dprio0_cnt_odd_div_even_duty_en_16 (c_cnt_odd_div_duty_en16),
                .c_cnt_prst_16 (c_cnt_prst16),
                .c_cnt_ph_mux_prst_16 (c_cnt_ph_mux_prst16),
                .output_clock_frequency_17 (output_clock_frequency17),
				.phase_shift_17(phase_shift17),
                .dprio0_cnt_hi_div_17 (c_cnt_hi_div17), 
                .dprio0_cnt_lo_div_17 (c_cnt_lo_div17),
                .dprio0_cnt_bypass_en_17 (c_cnt_bypass_en17),
                .dprio0_cnt_odd_div_even_duty_en_17 (c_cnt_odd_div_duty_en17),
                .c_cnt_prst_17 (c_cnt_prst17),
                .c_cnt_ph_mux_prst_17 (c_cnt_ph_mux_prst17),
				//duty cycle params
				.duty_cycle_0(duty_cycle0),
				.duty_cycle_1(duty_cycle1),
				.duty_cycle_2(duty_cycle2),
				.duty_cycle_3(duty_cycle3),
				.duty_cycle_4(duty_cycle4),
				.duty_cycle_5(duty_cycle5),
				.duty_cycle_6(duty_cycle6),
				.duty_cycle_7(duty_cycle7),
				.duty_cycle_8(duty_cycle8),
				.duty_cycle_9(duty_cycle9),
				.duty_cycle_10(duty_cycle10),
				.duty_cycle_11(duty_cycle11),
				.duty_cycle_12(duty_cycle12),
				.duty_cycle_13(duty_cycle13),
				.duty_cycle_14(duty_cycle14),
				.duty_cycle_15(duty_cycle15),
				.duty_cycle_16(duty_cycle16),
				.duty_cycle_17(duty_cycle17),
                //output counter cascading params
                .c_cnt_in_src_0 (c_cnt_in_src0),
                .c_cnt_in_src_1 (c_cnt_in_src1),
                .c_cnt_in_src_2 (c_cnt_in_src2),
                .c_cnt_in_src_3 (c_cnt_in_src3),
                .c_cnt_in_src_4 (c_cnt_in_src4),
                .c_cnt_in_src_5 (c_cnt_in_src5),
                .c_cnt_in_src_6 (c_cnt_in_src6),
                .c_cnt_in_src_7 (c_cnt_in_src7),
                .c_cnt_in_src_8 (c_cnt_in_src8),
                .c_cnt_in_src_9 (c_cnt_in_src9),
                .c_cnt_in_src_10 (c_cnt_in_src10),
                .c_cnt_in_src_11 (c_cnt_in_src11),
                .c_cnt_in_src_12 (c_cnt_in_src12),
                .c_cnt_in_src_13 (c_cnt_in_src13),
                .c_cnt_in_src_14 (c_cnt_in_src14),
                .c_cnt_in_src_15 (c_cnt_in_src15),
                .c_cnt_in_src_16 (c_cnt_in_src16),
                .c_cnt_in_src_17 (c_cnt_in_src17),
                //refclk select params
                .pll_auto_clk_sw_en_0 (pll_auto_clk_sw_en),
                .pll_clk_loss_sw_en_0 (pll_clk_loss_sw_en),
                .pll_clk_sw_dly_0    (pll_clk_sw_dly),
                .pll_clkin_0_src_0   (pll_clkin_0_src),
                .pll_clkin_1_src_0   (pll_clkin_1_src),
                .pll_manu_clk_sw_en_0  (pll_manu_clk_sw_en),
				.pll_vcoph_div_0 (pll_vcoph_div)
        )

             arriav_pll (
                // arriav_pll_dpa_output pins
                .phout_0(phout_wire),
                .phout_1(),
                
                // arriav_pll_refclk_select pins
                .adjpllin(adjpllin),    
                .cclk(cclk),
                .coreclkin(),
                .extswitch(extswitch),
                .iqtxrxclkin(),
                .plliqclkin(),
                .rxiqclkin(),
                .clkin({2'b0,refclk1, refclk}),
                .refiqclk_0(),
                .refiqclk_1(),
                .clk0bad(clkbad_wire[0]),
                .clk1bad(clkbad_wire[1]),
                .pllclksel(activeclk_wire),

                // arriav_pll_reconfig pins
                .atpgmode(),
                .clk(pll_subtype != "General" ? ((pll_subtype == "DPS") ? scanclk : reconfig_to_pll[0]) : 1'b0),
                .fpllcsrtest(),
                .iocsrclkin(),
                .iocsrdatain(),
                .iocsren(),
                .iocsrrstn(),
                .mdiodis(pll_subtype != "General" ? ((pll_subtype == "DPS") ? 1'b1 : reconfig_to_pll[29]) : 1'b1),
                .phaseen(final_phase_en),
                .read(reconfig_to_pll[3]),
                .rstn(pll_subtype != "General" ? ((pll_subtype == "DPS") ? ~rst : reconfig_to_pll[1]): 1'b1),
                .scanen(),
                .sershiftload(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_ser_shift_load : reconfig_to_pll[28]) : 1'b1),
                .shiftdonei(),
                .updn(pll_subtype != "General" ? ((pll_subtype == "ReconfDPS") || (pll_subtype == "DPS") ? updn:reconfig_to_pll[31]) : 1'b0),
                .write(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_write : reconfig_to_pll[2]) :1'b0),
                .addr_0(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_address : reconfig_to_pll[9:4]) :6'b000000),
                .addr_1(),
                .byteen_0(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_byteen : reconfig_to_pll[27:26]) :2'b00),
                .byteen_1(),
                .cntsel_0(pll_subtype != "General" ? ((pll_subtype == "ReconfDPS") || (pll_subtype == "DPS") ? cntsel_int:reconfig_to_pll[36:32]) : 5'b00000),
                .cntsel_1(),
                .din_0(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_writedata : reconfig_to_pll[25:10]) :16'h0000),
                .din_1(),
                .blockselect(),
                .iocsrdataout(),
                .iocsrenbuf(),
                .iocsrrstnbuf(),
                .phasedone(reconfig_from_pll_wire[17]),
                .dout_0(reconfig_from_pll_wire[15:0]),
                .dout_1(),
                .dprioout_0(),
                .dprioout_1(),
                
                // arriav_fractional_pll pins
                .fbclkfpll(),
                .lvdfbin((operation_mode == "lvds") ? lvds_fbclk : 1'b0),
                .nresync(~rst),
                .pfden(1'b1),
                .shiften_fpll(),
                .zdb((operation_mode == "external feedback") ? fb_clkin : (operation_mode == "zero delay buffer") ? fb_out_clk : 1'b0),
                .fblvdsout(lvds_fbclk),
                .lock(reconfig_from_pll_wire[16]),
                .mcntout(),
                .plniotribuf(),

                // arriav_pll_extclk_output pins
                .clken(),
                .extclk(fboutclk_wire[0]),

                // arriav_pll_dll_output pins
                .dll_clkin(),
                .clkout(),

                // arriav_pll_lvds_output pins
                .loaden(),
                .lvdsclk(),

                // arriav_pll_output_counter pins
                .divclk(divclk_wire),
				.cascade_out(cascade_out_wire)				
                );
                
                assign locked_wire[0] = reconfig_from_pll_wire[16]; 
                assign outclk_wire = divclk_wire;
            end 
            else if (pll_type == "Arria V GZ")
            begin 
            assign cntsel_temp = cntsel;
            assign gnd = 1'b0;

            //cnt select luts (5)
            altera_pll_dps_lcell_comb lcell_cntsel_int_0 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[0]));
            defparam lcell_cntsel_int_0.lut_mask = 64'hAAAAAAAAAAAAAAAA;
            defparam lcell_cntsel_int_0.dont_touch = "on";
            defparam lcell_cntsel_int_0.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_1 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[1]));
            defparam lcell_cntsel_int_1.lut_mask = 64'hCCCCCCCCCCCCCCCC;
            defparam lcell_cntsel_int_1.dont_touch = "on";
            defparam lcell_cntsel_int_1.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_2 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[2]));
            defparam lcell_cntsel_int_2.lut_mask = 64'hF0F0F0F0F0F0F0F0;
            defparam lcell_cntsel_int_2.dont_touch = "on";
            defparam lcell_cntsel_int_2.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_3 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[3]));
            defparam lcell_cntsel_int_3.lut_mask = 64'hFF00FF00FF00FF00;
            defparam lcell_cntsel_int_3.dont_touch = "on";
            defparam lcell_cntsel_int_3.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_4 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[4]));
            defparam lcell_cntsel_int_4.lut_mask = 64'hFFFF0000FFFF0000;
            defparam lcell_cntsel_int_4.dont_touch = "on";
            defparam lcell_cntsel_int_4.family = pll_type;
   
            altera_arriavgz_pll #(
                .number_of_fplls(1),
                .pll_vco_div_0(pll_vco_div),
				.pll_slf_rst_0(pll_slf_rst),
                .reference_clock_frequency_0 (reference_clock_frequency),
                .pll_output_clock_frequency_0 (pll_output_clk_frequency),
                .dpa_output_clock_frequency_0 (pll_output_clk_frequency),
                .enable_output_counter_0 ((number_of_clocks >= 1) ? "true" : "false"),
                .enable_output_counter_1 ((number_of_clocks >= 2) ? "true" : "false"),
                .enable_output_counter_2 ((number_of_clocks >= 3) ? "true" : "false"),
                .enable_output_counter_3 ((number_of_clocks >= 4) ? "true" : "false"),
                .enable_output_counter_4 ((number_of_clocks >= 5) ? "true" : "false"),
                .enable_output_counter_5 ((number_of_clocks >= 6) ? "true" : "false"),
                .enable_output_counter_6 ((number_of_clocks >= 7) ? "true" : "false"),
                .enable_output_counter_7 ((number_of_clocks >= 8) ? "true" : "false"),
                .enable_output_counter_8 ((number_of_clocks >= 9) ? "true" : "false"),
                .enable_output_counter_9 ((number_of_clocks >= 10) ? "true" : "false"),
                .enable_output_counter_10 ((number_of_clocks >= 11) ? "true" : "false"),
                .enable_output_counter_11 ((number_of_clocks >= 12) ? "true" : "false"),
                .enable_output_counter_12 ((number_of_clocks >= 13) ? "true" : "false"),
                .enable_output_counter_13 ((number_of_clocks >= 14) ? "true" : "false"),
                .enable_output_counter_14 ((number_of_clocks >= 15) ? "true" : "false"),
                .enable_output_counter_15 ((number_of_clocks >= 16) ? "true" : "false"),
                .enable_output_counter_16 ((number_of_clocks >= 17) ? "true" : "false"),
                .enable_output_counter_17 ((number_of_clocks >= 18) ? "true" : "false"),
                .number_of_extclks ((operation_mode == "external feedback" || operation_mode == "zero delay buffer") ? 1 : 0),
                .enable_extclk_output_0 ((operation_mode == "external feedback" || operation_mode == "zero delay buffer") ? "true" : "false"),
                .number_of_counters(number_of_clocks),
                .pll_dsm_out_sel_0((fractional_vco_multiplier == "true") ? pll_dsm_out_sel : "disable"),
                .pll_dsm_dither_0((fractional_vco_multiplier == "true") ? "disable" : "disable"),
                .pll_cp_current_0 (pll_cp_current),
                .pll_fractional_division_0 (pll_fractional_division),
                .pll_fractional_carry_out_0 (pll_fractional_cout),
                .pll_bwctrl_0 (pll_bwctrl),
                .mimic_fbclk_type_0 (mimic_fbclk_type),
                .pll_fbclk_mux_1_0 (pll_fbclk_mux_1),
                .pll_fbclk_mux_2_0 (pll_fbclk_mux_2),
                .pll_m_cnt_in_src_0 (pll_m_cnt_in_src),
                .pll_m_cnt_hi_div_0(m_cnt_hi_div),
                .pll_m_cnt_lo_div_0 (m_cnt_lo_div),
                .pll_m_cnt_bypass_en_0 (m_cnt_bypass_en),
                .pll_m_cnt_odd_div_duty_en_0 (m_cnt_odd_div_duty_en),
                .pll_n_cnt_hi_div_0 (n_cnt_hi_div),
                .pll_n_cnt_lo_div_0 (n_cnt_lo_div),
                .pll_n_cnt_bypass_en_0 (n_cnt_bypass_en),
                .pll_n_cnt_odd_div_duty_en_0 (n_cnt_odd_div_duty_en),
                .output_clock_frequency_0 (output_clock_frequency0),
				.phase_shift_0(phase_shift0),
                .dprio0_cnt_hi_div_0 (c_cnt_hi_div0), 
                .dprio0_cnt_lo_div_0 (c_cnt_lo_div0),
                .dprio0_cnt_bypass_en_0 (c_cnt_bypass_en0),
                .dprio0_cnt_odd_div_even_duty_en_0 (c_cnt_odd_div_duty_en0),
                .c_cnt_prst_0 (c_cnt_prst0),
                .c_cnt_ph_mux_prst_0 (c_cnt_ph_mux_prst0),
                .output_clock_frequency_1 (output_clock_frequency1),
				.phase_shift_1(phase_shift1),
                .dprio0_cnt_hi_div_1 (c_cnt_hi_div1), 
                .dprio0_cnt_lo_div_1 (c_cnt_lo_div1),
                .dprio0_cnt_bypass_en_1 (c_cnt_bypass_en1),
                .dprio0_cnt_odd_div_even_duty_en_1 (c_cnt_odd_div_duty_en1),
                .c_cnt_prst_1 (c_cnt_prst1),
                .c_cnt_ph_mux_prst_1 (c_cnt_ph_mux_prst1),
                .output_clock_frequency_2 (output_clock_frequency2),
				.phase_shift_2(phase_shift2),
                .dprio0_cnt_hi_div_2 (c_cnt_hi_div2), 
                .dprio0_cnt_lo_div_2 (c_cnt_lo_div2),
                .dprio0_cnt_bypass_en_2 (c_cnt_bypass_en2),
                .dprio0_cnt_odd_div_even_duty_en_2 (c_cnt_odd_div_duty_en2),
                .c_cnt_prst_2 (c_cnt_prst2),
                .c_cnt_ph_mux_prst_2 (c_cnt_ph_mux_prst2),
                .output_clock_frequency_3 (output_clock_frequency3),
				.phase_shift_3(phase_shift3),
                .dprio0_cnt_hi_div_3 (c_cnt_hi_div3), 
                .dprio0_cnt_lo_div_3 (c_cnt_lo_div3),
                .dprio0_cnt_bypass_en_3 (c_cnt_bypass_en3),
                .dprio0_cnt_odd_div_even_duty_en_3 (c_cnt_odd_div_duty_en3),
                .c_cnt_prst_3 (c_cnt_prst3),
                .c_cnt_ph_mux_prst_3 (c_cnt_ph_mux_prst3),
                .output_clock_frequency_4 (output_clock_frequency4),
				.phase_shift_4(phase_shift4),
                .dprio0_cnt_hi_div_4 (c_cnt_hi_div4), 
                .dprio0_cnt_lo_div_4 (c_cnt_lo_div4),
                .dprio0_cnt_bypass_en_4 (c_cnt_bypass_en4),
                .dprio0_cnt_odd_div_even_duty_en_4 (c_cnt_odd_div_duty_en4),
                .c_cnt_prst_4 (c_cnt_prst4),
                .c_cnt_ph_mux_prst_4 (c_cnt_ph_mux_prst4),
                .output_clock_frequency_5 (output_clock_frequency5),
				.phase_shift_5(phase_shift5),
                .dprio0_cnt_hi_div_5 (c_cnt_hi_div5), 
                .dprio0_cnt_lo_div_5 (c_cnt_lo_div5),
                .dprio0_cnt_bypass_en_5 (c_cnt_bypass_en5),
                .dprio0_cnt_odd_div_even_duty_en_5 (c_cnt_odd_div_duty_en5),
                .c_cnt_prst_5 (c_cnt_prst5),
                .c_cnt_ph_mux_prst_5 (c_cnt_ph_mux_prst5),
                .output_clock_frequency_6 (output_clock_frequency6),
				.phase_shift_6(phase_shift6),
                .dprio0_cnt_hi_div_6 (c_cnt_hi_div6), 
                .dprio0_cnt_lo_div_6 (c_cnt_lo_div6),
                .dprio0_cnt_bypass_en_6 (c_cnt_bypass_en6),
                .dprio0_cnt_odd_div_even_duty_en_6 (c_cnt_odd_div_duty_en6),
                .c_cnt_prst_6 (c_cnt_prst6),
                .c_cnt_ph_mux_prst_6 (c_cnt_ph_mux_prst6),
                .output_clock_frequency_7 (output_clock_frequency7),
				.phase_shift_7(phase_shift7),
                .dprio0_cnt_hi_div_7 (c_cnt_hi_div7), 
                .dprio0_cnt_lo_div_7 (c_cnt_lo_div7),
                .dprio0_cnt_bypass_en_7 (c_cnt_bypass_en7),
                .dprio0_cnt_odd_div_even_duty_en_7 (c_cnt_odd_div_duty_en7),
                .c_cnt_prst_7 (c_cnt_prst7),
                .c_cnt_ph_mux_prst_7 (c_cnt_ph_mux_prst7),
                .output_clock_frequency_8 (output_clock_frequency8),
				.phase_shift_8(phase_shift8),
                .dprio0_cnt_hi_div_8 (c_cnt_hi_div8), 
                .dprio0_cnt_lo_div_8 (c_cnt_lo_div8),
                .dprio0_cnt_bypass_en_8 (c_cnt_bypass_en8),
                .dprio0_cnt_odd_div_even_duty_en_8 (c_cnt_odd_div_duty_en8),
                .c_cnt_prst_8 (c_cnt_prst8),
                .c_cnt_ph_mux_prst_8 (c_cnt_ph_mux_prst8),
                .output_clock_frequency_9 (output_clock_frequency9),
				.phase_shift_9(phase_shift9),
                .dprio0_cnt_hi_div_9 (c_cnt_hi_div9), 
                .dprio0_cnt_lo_div_9 (c_cnt_lo_div9),
                .dprio0_cnt_bypass_en_9 (c_cnt_bypass_en9),
                .dprio0_cnt_odd_div_even_duty_en_9 (c_cnt_odd_div_duty_en9),
                .c_cnt_prst_9 (c_cnt_prst9),
                .c_cnt_ph_mux_prst_9 (c_cnt_ph_mux_prst9),
                .output_clock_frequency_10 (output_clock_frequency10),
				.phase_shift_10(phase_shift10),
                .dprio0_cnt_hi_div_10 (c_cnt_hi_div10), 
                .dprio0_cnt_lo_div_10 (c_cnt_lo_div10),
                .dprio0_cnt_bypass_en_10 (c_cnt_bypass_en10),
                .dprio0_cnt_odd_div_even_duty_en_10 (c_cnt_odd_div_duty_en10),
                .c_cnt_prst_10 (c_cnt_prst10),
                .c_cnt_ph_mux_prst_10 (c_cnt_ph_mux_prst10),
                .output_clock_frequency_11 (output_clock_frequency11),
				.phase_shift_11(phase_shift11),
                .dprio0_cnt_hi_div_11 (c_cnt_hi_div11), 
                .dprio0_cnt_lo_div_11 (c_cnt_lo_div11),
                .dprio0_cnt_bypass_en_11 (c_cnt_bypass_en11),
                .dprio0_cnt_odd_div_even_duty_en_11 (c_cnt_odd_div_duty_en11),
                .c_cnt_prst_11 (c_cnt_prst11),
                .c_cnt_ph_mux_prst_11 (c_cnt_ph_mux_prst11),
                .output_clock_frequency_12 (output_clock_frequency12),
				.phase_shift_12(phase_shift12),
                .dprio0_cnt_hi_div_12 (c_cnt_hi_div12), 
                .dprio0_cnt_lo_div_12 (c_cnt_lo_div12),
                .dprio0_cnt_bypass_en_12 (c_cnt_bypass_en12),
                .dprio0_cnt_odd_div_even_duty_en_12 (c_cnt_odd_div_duty_en12),
                .c_cnt_prst_12 (c_cnt_prst12),
                .c_cnt_ph_mux_prst_12 (c_cnt_ph_mux_prst12),
                .output_clock_frequency_13 (output_clock_frequency13),
				.phase_shift_13(phase_shift13),
                .dprio0_cnt_hi_div_13 (c_cnt_hi_div13), 
                .dprio0_cnt_lo_div_13 (c_cnt_lo_div13),
                .dprio0_cnt_bypass_en_13 (c_cnt_bypass_en13),
                .dprio0_cnt_odd_div_even_duty_en_13 (c_cnt_odd_div_duty_en13),
                .c_cnt_prst_13 (c_cnt_prst13),
                .c_cnt_ph_mux_prst_13 (c_cnt_ph_mux_prst13),
                .output_clock_frequency_14 (output_clock_frequency14),
				.phase_shift_14(phase_shift14),
                .dprio0_cnt_hi_div_14 (c_cnt_hi_div14), 
                .dprio0_cnt_lo_div_14 (c_cnt_lo_div14),
                .dprio0_cnt_bypass_en_14 (c_cnt_bypass_en14),
                .dprio0_cnt_odd_div_even_duty_en_14 (c_cnt_odd_div_duty_en14),
                .c_cnt_prst_14 (c_cnt_prst14),
                .c_cnt_ph_mux_prst_14 (c_cnt_ph_mux_prst14),
                .output_clock_frequency_15 (output_clock_frequency15),
				.phase_shift_15(phase_shift15),
                .dprio0_cnt_hi_div_15 (c_cnt_hi_div15), 
                .dprio0_cnt_lo_div_15 (c_cnt_lo_div15),
                .dprio0_cnt_bypass_en_15 (c_cnt_bypass_en15),
                .dprio0_cnt_odd_div_even_duty_en_15 (c_cnt_odd_div_duty_en15),
                .c_cnt_prst_15 (c_cnt_prst15),
                .c_cnt_ph_mux_prst_15 (c_cnt_ph_mux_prst15),
                .output_clock_frequency_16 (output_clock_frequency16),
				.phase_shift_16(phase_shift16),
                .dprio0_cnt_hi_div_16 (c_cnt_hi_div16), 
                .dprio0_cnt_lo_div_16 (c_cnt_lo_div16),
                .dprio0_cnt_bypass_en_16 (c_cnt_bypass_en16),
                .dprio0_cnt_odd_div_even_duty_en_16 (c_cnt_odd_div_duty_en16),
                .c_cnt_prst_16 (c_cnt_prst16),
                .c_cnt_ph_mux_prst_16 (c_cnt_ph_mux_prst16),
                .output_clock_frequency_17 (output_clock_frequency17),
				.phase_shift_17(phase_shift17),
                .dprio0_cnt_hi_div_17 (c_cnt_hi_div17), 
                .dprio0_cnt_lo_div_17 (c_cnt_lo_div17),
                .dprio0_cnt_bypass_en_17 (c_cnt_bypass_en17),
                .dprio0_cnt_odd_div_even_duty_en_17 (c_cnt_odd_div_duty_en17),
                .c_cnt_prst_17 (c_cnt_prst17),
                .c_cnt_ph_mux_prst_17 (c_cnt_ph_mux_prst17),
				//duty cycle params
				.duty_cycle_0(duty_cycle0),
				.duty_cycle_1(duty_cycle1),
				.duty_cycle_2(duty_cycle2),
				.duty_cycle_3(duty_cycle3),
				.duty_cycle_4(duty_cycle4),
				.duty_cycle_5(duty_cycle5),
				.duty_cycle_6(duty_cycle6),
				.duty_cycle_7(duty_cycle7),
				.duty_cycle_8(duty_cycle8),
				.duty_cycle_9(duty_cycle9),
				.duty_cycle_10(duty_cycle10),
				.duty_cycle_11(duty_cycle11),
				.duty_cycle_12(duty_cycle12),
				.duty_cycle_13(duty_cycle13),
				.duty_cycle_14(duty_cycle14),
				.duty_cycle_15(duty_cycle15),
				.duty_cycle_16(duty_cycle16),
				.duty_cycle_17(duty_cycle17),
				//output counter cascading params
                .c_cnt_in_src_0 (c_cnt_in_src0),
                .c_cnt_in_src_1 (c_cnt_in_src1),
                .c_cnt_in_src_2 (c_cnt_in_src2),
                .c_cnt_in_src_3 (c_cnt_in_src3),
                .c_cnt_in_src_4 (c_cnt_in_src4),
                .c_cnt_in_src_5 (c_cnt_in_src5),
                .c_cnt_in_src_6 (c_cnt_in_src6),
                .c_cnt_in_src_7 (c_cnt_in_src7),
                .c_cnt_in_src_8 (c_cnt_in_src8),
                .c_cnt_in_src_9 (c_cnt_in_src9),
                .c_cnt_in_src_10 (c_cnt_in_src10),
                .c_cnt_in_src_11 (c_cnt_in_src11),
                .c_cnt_in_src_12 (c_cnt_in_src12),
                .c_cnt_in_src_13 (c_cnt_in_src13),
                .c_cnt_in_src_14 (c_cnt_in_src14),
                .c_cnt_in_src_15 (c_cnt_in_src15),
                .c_cnt_in_src_16 (c_cnt_in_src16),
                .c_cnt_in_src_17 (c_cnt_in_src17),
                //refclk select params
                .pll_auto_clk_sw_en_0 (pll_auto_clk_sw_en),
                .pll_clk_loss_sw_en_0 (pll_clk_loss_sw_en),
                .pll_clk_sw_dly_0    (pll_clk_sw_dly),
                .pll_clkin_0_src_0   (pll_clkin_0_src),
                .pll_clkin_1_src_0   (pll_clkin_1_src),
                .pll_manu_clk_sw_en_0  (pll_manu_clk_sw_en),
				.pll_vcoph_div_0 (pll_vcoph_div)
			)
             arriavgz_pll (
                // stratixv_pll_dpa_output pins
                .phout_0(phout_wire),
                .phout_1(),
                
                // stratixv_pll_refclk_select pins
                .adjpllin(adjpllin),    
                .cclk(cclk),
                .coreclkin(),
                .extswitch(extswitch),
                .iqtxrxclkin(),
                .plliqclkin(),
                .rxiqclkin(),
                .clkin({2'b0,refclk1, refclk}),
                .refiqclk_0(),
                .refiqclk_1(),
                .clk0bad(clkbad_wire[0]),
                .clk1bad(clkbad_wire[1]),
                .pllclksel(activeclk_wire),

                // stratixv_pll_reconfig pins
                .atpgmode(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_atpgmode : reconfig_to_pll[38]) : 1'b0),
                .clk(pll_subtype != "General" ? ((pll_subtype == "DPS") ? scanclk : reconfig_to_pll[0]) : 1'b0),
                .fpllcsrtest(reconfig_to_pll[38]),
                .iocsrclkin(),
                .iocsrdatain(),
                .iocsren(),
                .iocsrrstn(),
                .mdiodis(pll_subtype != "General" ? ((pll_subtype == "DPS") ? 1'b1 : reconfig_to_pll[29]) : 1'b1),
                .phaseen(final_phase_en),
                .read(reconfig_to_pll[3]),
                .rstn(pll_subtype != "General" ? ((pll_subtype == "DPS") ? ~rst : reconfig_to_pll[1]): 1'b1),
                .scanen(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_scanen : reconfig_to_pll[37]) : 1'b0),
                .sershiftload(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_ser_shift_load : reconfig_to_pll[28]) : 1'b1),
                .shiftdonei(),
                .updn(pll_subtype != "General" ? ((pll_subtype == "ReconfDPS") || (pll_subtype == "DPS") ? updn:reconfig_to_pll[31]) : 1'b0),
                .write(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_write : reconfig_to_pll[2]) :1'b0),
                .addr_0(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_address : reconfig_to_pll[9:4]) :6'b000000),
                .addr_1(),
                .byteen_0(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_byteen : reconfig_to_pll[27:26]) :2'b00),
                .byteen_1(),
                .cntsel_0(pll_subtype != "General" ? ((pll_subtype == "ReconfDPS") || (pll_subtype == "DPS") ? cntsel_int:reconfig_to_pll[36:32]) : 5'b00000),
                .cntsel_1(),
                .din_0(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_writedata : reconfig_to_pll[25:10]) :16'h0000),
                .din_1(),
                .blockselect(),
                .iocsrdataout(),
                .iocsrenbuf(),
                .iocsrrstnbuf(),
                .phasedone(reconfig_from_pll_wire[17]),
                .dout_0(reconfig_from_pll_wire[15:0]),
                .dout_1(),
                .dprioout_0(),
                .dprioout_1(),
                
                // stratixv_fractional_pll pins
                .fbclkfpll(),
                .lvdfbin((operation_mode == "lvds") ? lvds_fbclk : 1'b0),
                .nresync(~rst),
                .pfden(1'b1),
                .shiften_fpll(),
                .zdb((operation_mode == "external feedback") ? fb_clkin : (operation_mode == "zero delay buffer") ? fb_out_clk : 1'b0),
                .fblvdsout(lvds_fbclk),
                .lock(reconfig_from_pll_wire[16]),
                .mcntout(),
                .plniotribuf(),

                // stratixv_pll_extclk_output pins
                .clken(),
                .extclk(fboutclk_wire[0]),

                // stratixv_pll_dll_output pins
                .dll_clkin(),
                .clkout(),

                // stratixv_pll_lvds_output pins
                .loaden(),
                .lvdsclk(),

                // stratixv_pll_output_counter pins
                .divclk(divclk_wire),
				.cascade_out(cascade_out_wire)
                );
                
                assign locked_wire[0] = reconfig_from_pll_wire[16]; 
                assign outclk_wire = divclk_wire;
            end
            else if (pll_type == "Cyclone V") 
            begin    
            assign cntsel_temp = cntsel;
            assign gnd = 1'b0;

            //cnt select luts (5)
            altera_pll_dps_lcell_comb lcell_cntsel_int_0 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[0]));
            defparam lcell_cntsel_int_0.lut_mask = 64'hAAAAAAAAAAAAAAAA;
            defparam lcell_cntsel_int_0.dont_touch = "on";
            defparam lcell_cntsel_int_0.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_1 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[1]));
            defparam lcell_cntsel_int_1.lut_mask = 64'hCCCCCCCCCCCCCCCC;
            defparam lcell_cntsel_int_1.dont_touch = "on";
            defparam lcell_cntsel_int_1.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_2 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[2]));
            defparam lcell_cntsel_int_2.lut_mask = 64'hF0F0F0F0F0F0F0F0;
            defparam lcell_cntsel_int_2.dont_touch = "on";
            defparam lcell_cntsel_int_2.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_3 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[3]));
            defparam lcell_cntsel_int_3.lut_mask = 64'hFF00FF00FF00FF00;
            defparam lcell_cntsel_int_3.dont_touch = "on";
            defparam lcell_cntsel_int_3.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_4 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(cntsel_temp[4]),
                .dataf(gnd),
                .combout (cntsel_int[4]));
            defparam lcell_cntsel_int_4.lut_mask = 64'hFFFF0000FFFF0000;
            defparam lcell_cntsel_int_4.dont_touch = "on";
            defparam lcell_cntsel_int_4.family = pll_type;
   
            altera_cyclonev_pll #(
                .number_of_fplls(1),
                .pll_vco_div_0(pll_vco_div),
				.pll_slf_rst_0(pll_slf_rst),
                .reference_clock_frequency_0 (reference_clock_frequency),
                .pll_output_clock_frequency_0 (pll_output_clk_frequency),
                .dpa_output_clock_frequency_0 (pll_output_clk_frequency),
                .enable_output_counter_0 ((number_of_clocks >= 1) ? "true" : "false"),
                .enable_output_counter_1 ((number_of_clocks >= 2) ? "true" : "false"),
                .enable_output_counter_2 ((number_of_clocks >= 3) ? "true" : "false"),
                .enable_output_counter_3 ((number_of_clocks >= 4) ? "true" : "false"),
                .enable_output_counter_4 ((number_of_clocks >= 5) ? "true" : "false"),
                .enable_output_counter_5 ((number_of_clocks >= 6) ? "true" : "false"),
                .enable_output_counter_6 ((number_of_clocks >= 7) ? "true" : "false"),
                .enable_output_counter_7 ((number_of_clocks >= 8) ? "true" : "false"),
                .enable_output_counter_8 ((number_of_clocks >= 9) ? "true" : "false"),
                .number_of_extclks ((operation_mode == "external feedback" || operation_mode == "zero delay buffer") ? 1 : 0),
                .enable_extclk_output_0 ((operation_mode == "external feedback" || operation_mode == "zero delay buffer") ? "true" : "false"),
                .number_of_counters(number_of_clocks),
                .pll_dsm_out_sel_0((fractional_vco_multiplier == "true") ? pll_dsm_out_sel : "disable"),
                .pll_dsm_dither_0((fractional_vco_multiplier == "true") ? "disable" : "disable"),
                .pll_cp_current_0 (pll_cp_current),
                .pll_fractional_division_0 (pll_fractional_division),
                .pll_fractional_carry_out_0 (pll_fractional_cout),
                .pll_bwctrl_0 (pll_bwctrl),
                .mimic_fbclk_type_0 (mimic_fbclk_type),
                .pll_fbclk_mux_1_0 (pll_fbclk_mux_1),
                .pll_fbclk_mux_2_0 (pll_fbclk_mux_2),
                .pll_m_cnt_in_src_0 (pll_m_cnt_in_src),
                .pll_m_cnt_hi_div_0(m_cnt_hi_div),
                .pll_m_cnt_lo_div_0 (m_cnt_lo_div),
                .pll_m_cnt_bypass_en_0 (m_cnt_bypass_en),
                .pll_m_cnt_odd_div_duty_en_0 (m_cnt_odd_div_duty_en),
                .pll_n_cnt_hi_div_0 (n_cnt_hi_div),
                .pll_n_cnt_lo_div_0 (n_cnt_lo_div),
                .pll_n_cnt_bypass_en_0 (n_cnt_bypass_en),
                .pll_n_cnt_odd_div_duty_en_0 (n_cnt_odd_div_duty_en),
                .output_clock_frequency_0 (output_clock_frequency0),
                .phase_shift_0(phase_shift0),
                .dprio0_cnt_hi_div_0 (c_cnt_hi_div0), 
                .dprio0_cnt_lo_div_0 (c_cnt_lo_div0),
                .dprio0_cnt_bypass_en_0 (c_cnt_bypass_en0),
                .dprio0_cnt_odd_div_even_duty_en_0 (c_cnt_odd_div_duty_en0),
                .c_cnt_prst_0 (c_cnt_prst0),
                .c_cnt_ph_mux_prst_0 (c_cnt_ph_mux_prst0),
                .output_clock_frequency_1 (output_clock_frequency1),
                .phase_shift_1(phase_shift1),
                .dprio0_cnt_hi_div_1 (c_cnt_hi_div1), 
                .dprio0_cnt_lo_div_1 (c_cnt_lo_div1),
                .dprio0_cnt_bypass_en_1 (c_cnt_bypass_en1),
                .dprio0_cnt_odd_div_even_duty_en_1 (c_cnt_odd_div_duty_en1),
                .c_cnt_prst_1 (c_cnt_prst1),
                .c_cnt_ph_mux_prst_1 (c_cnt_ph_mux_prst1),
                .output_clock_frequency_2 (output_clock_frequency2),
                .phase_shift_2(phase_shift2),
                .dprio0_cnt_hi_div_2 (c_cnt_hi_div2), 
                .dprio0_cnt_lo_div_2 (c_cnt_lo_div2),
                .dprio0_cnt_bypass_en_2 (c_cnt_bypass_en2),
                .dprio0_cnt_odd_div_even_duty_en_2 (c_cnt_odd_div_duty_en2),
                .c_cnt_prst_2 (c_cnt_prst2),
                .c_cnt_ph_mux_prst_2 (c_cnt_ph_mux_prst2),
                .output_clock_frequency_3 (output_clock_frequency3),
                .phase_shift_3(phase_shift3),
                .dprio0_cnt_hi_div_3 (c_cnt_hi_div3), 
                .dprio0_cnt_lo_div_3 (c_cnt_lo_div3),
                .dprio0_cnt_bypass_en_3 (c_cnt_bypass_en3),
                .dprio0_cnt_odd_div_even_duty_en_3 (c_cnt_odd_div_duty_en3),
                .c_cnt_prst_3 (c_cnt_prst3),
                .c_cnt_ph_mux_prst_3 (c_cnt_ph_mux_prst3),
                .output_clock_frequency_4 (output_clock_frequency4),
                .phase_shift_4(phase_shift4),
                .dprio0_cnt_hi_div_4 (c_cnt_hi_div4), 
                .dprio0_cnt_lo_div_4 (c_cnt_lo_div4),
                .dprio0_cnt_bypass_en_4 (c_cnt_bypass_en4),
                .dprio0_cnt_odd_div_even_duty_en_4 (c_cnt_odd_div_duty_en4),
                .c_cnt_prst_4 (c_cnt_prst4),
                .c_cnt_ph_mux_prst_4 (c_cnt_ph_mux_prst4),
                .output_clock_frequency_5 (output_clock_frequency5),
                .phase_shift_5(phase_shift5),
                .dprio0_cnt_hi_div_5 (c_cnt_hi_div5), 
                .dprio0_cnt_lo_div_5 (c_cnt_lo_div5),
                .dprio0_cnt_bypass_en_5 (c_cnt_bypass_en5),
                .dprio0_cnt_odd_div_even_duty_en_5 (c_cnt_odd_div_duty_en5),
                .c_cnt_prst_5 (c_cnt_prst5),
                .c_cnt_ph_mux_prst_5 (c_cnt_ph_mux_prst5),
                .output_clock_frequency_6 (output_clock_frequency6),
                .phase_shift_6(phase_shift6),
                .dprio0_cnt_hi_div_6 (c_cnt_hi_div6), 
                .dprio0_cnt_lo_div_6 (c_cnt_lo_div6),
                .dprio0_cnt_bypass_en_6 (c_cnt_bypass_en6),
                .dprio0_cnt_odd_div_even_duty_en_6 (c_cnt_odd_div_duty_en6),
                .c_cnt_prst_6 (c_cnt_prst6),
                .c_cnt_ph_mux_prst_6 (c_cnt_ph_mux_prst6),
                .output_clock_frequency_7 (output_clock_frequency7),
                .phase_shift_7(phase_shift7),
                .dprio0_cnt_hi_div_7 (c_cnt_hi_div7), 
                .dprio0_cnt_lo_div_7 (c_cnt_lo_div7),
                .dprio0_cnt_bypass_en_7 (c_cnt_bypass_en7),
                .dprio0_cnt_odd_div_even_duty_en_7 (c_cnt_odd_div_duty_en7),
                .c_cnt_prst_7 (c_cnt_prst7),
                .c_cnt_ph_mux_prst_7 (c_cnt_ph_mux_prst7),
                .output_clock_frequency_8 (output_clock_frequency8),
                .phase_shift_8(phase_shift8),
                .dprio0_cnt_hi_div_8 (c_cnt_hi_div8), 
                .dprio0_cnt_lo_div_8 (c_cnt_lo_div8),
                .dprio0_cnt_bypass_en_8 (c_cnt_bypass_en8),
                .dprio0_cnt_odd_div_even_duty_en_8 (c_cnt_odd_div_duty_en8),
                .c_cnt_prst_8 (c_cnt_prst8),
                .c_cnt_ph_mux_prst_8 (c_cnt_ph_mux_prst8),
				//duty cycle params
				.duty_cycle_0(duty_cycle0),
				.duty_cycle_1(duty_cycle1),
				.duty_cycle_2(duty_cycle2),
				.duty_cycle_3(duty_cycle3),
				.duty_cycle_4(duty_cycle4),
				.duty_cycle_5(duty_cycle5),
				.duty_cycle_6(duty_cycle6),
				.duty_cycle_7(duty_cycle7),
				.duty_cycle_8(duty_cycle8),
				//output counter cascading params
                .c_cnt_in_src_0 (c_cnt_in_src0),
                .c_cnt_in_src_1 (c_cnt_in_src1),
                .c_cnt_in_src_2 (c_cnt_in_src2),
                .c_cnt_in_src_3 (c_cnt_in_src3),
                .c_cnt_in_src_4 (c_cnt_in_src4),
                .c_cnt_in_src_5 (c_cnt_in_src5),
                .c_cnt_in_src_6 (c_cnt_in_src6),
                .c_cnt_in_src_7 (c_cnt_in_src7),
                .c_cnt_in_src_8 (c_cnt_in_src8),
                //refclk select params
                .pll_auto_clk_sw_en_0 (pll_auto_clk_sw_en),
                .pll_clk_loss_sw_en_0 (pll_clk_loss_sw_en),
                .pll_clk_sw_dly_0    (pll_clk_sw_dly),
                .pll_clkin_0_src_0   (pll_clkin_0_src),
                .pll_clkin_1_src_0   (pll_clkin_1_src),
                .pll_manu_clk_sw_en_0  (pll_manu_clk_sw_en),
				.pll_vcoph_div_0 (pll_vcoph_div)
        )

             cyclonev_pll (
                // cyclonev_pll_dpa_output pins
                .phout_0(phout_wire),
                
                // cyclonev_pll_refclk_select pins
                .adjpllin(adjpllin),    
                .cclk(cclk),
                .coreclkin(),
                .extswitch(extswitch),
                .iqtxrxclkin(),
                .plliqclkin(),
                .rxiqclkin(),
                .clkin({2'b0,refclk1, refclk}),
                .refiqclk_0(),
                .refiqclk_1(),
                .clk0bad(clkbad_wire[0]),
                .clk1bad(clkbad_wire[1]),
                .pllclksel(activeclk_wire),

                // cyclonev_pll_reconfig pins
                .atpgmode(),
                .clk(pll_subtype != "General" ? ((pll_subtype == "DPS") ? scanclk : reconfig_to_pll[0]) : 1'b0),
                .fpllcsrtest(),
                .iocsrclkin(),
                .iocsrdatain(),
                .iocsren(),
                .iocsrrstn(),
                .mdiodis(pll_subtype != "General" ? ((pll_subtype == "DPS") ? 1'b1 : reconfig_to_pll[29]) : 1'b1),
                .phaseen(final_phase_en),
                .read(reconfig_to_pll[3]),
                .rstn(pll_subtype != "General" ? ((pll_subtype == "DPS") ? ~rst : reconfig_to_pll[1]): 1'b1),
                .scanen(),
                .sershiftload(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_ser_shift_load : reconfig_to_pll[28]) : 1'b1),
                .shiftdonei(),
                .updn(pll_subtype != "General" ? ((pll_subtype == "ReconfDPS") || (pll_subtype == "DPS") ? updn:reconfig_to_pll[31]) : 1'b0),
                .write(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_write : reconfig_to_pll[2]) :1'b0),
                .addr_0(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_address : reconfig_to_pll[9:4]) :6'b000000),
                .byteen_0(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_byteen : reconfig_to_pll[27:26]) :2'b00),
                .cntsel_0(pll_subtype != "General" ? ((pll_subtype == "ReconfDPS") || (pll_subtype == "DPS") ? cntsel_int:reconfig_to_pll[36:32]) : 5'b00000),
                .din_0(pll_subtype != "General" ? ((pll_subtype == "DPS") ? dps_writedata : reconfig_to_pll[25:10]) :16'h0000),
                .blockselect(),
                .iocsrdataout(),
                .iocsrenbuf(),
                .iocsrrstnbuf(),
                .phasedone(reconfig_from_pll_wire[17]),
                .dout_0(reconfig_from_pll_wire[15:0]),
                .dprioout_0(),
                
                // cyclonev_fractional_pll pins
                .fbclkfpll(),
                .lvdfbin((operation_mode == "lvds") ? lvds_fbclk : 1'b0),
                .nresync(~rst),
                .pfden(1'b1),
                .shiften_fpll(),
                .fblvdsout(lvds_fbclk),
                .zdb((operation_mode == "external feedback") ? fb_clkin : (operation_mode == "zero delay buffer") ? fb_out_clk : 1'b0),
                .lock(reconfig_from_pll_wire[16]),
                .mcntout(),
                .plniotribuf(),

                // cyclonev_pll_extclk_output pins
                .clken(),
                .extclk(fboutclk_wire[0]),

                // cyclonev_pll_dll_output pins
                .dll_clkin(),
                .clkout(),

                // cyclonev_pll_lvds_output pins
                .loaden(),
                .lvdsclk(),

                // cyclonev_pll_output_counter pins
                .divclk(divclk_wire),
				.cascade_out(cascade_out_wire)
                );
                
                assign locked_wire[0] = reconfig_from_pll_wire[16]; 
                assign outclk_wire = divclk_wire;
            end  
            else if (pll_type == "Arria 10") 
            begin    		
            assign cntsel_temp = cntsel;
            assign gnd = 1'b0;
   		
            //cnt select luts (5)
            altera_pll_dps_lcell_comb lcell_cntsel_int_0 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(gnd),
                .dataf(gnd),
                .combout (cntsel_int[0]));
            defparam lcell_cntsel_int_0.lut_mask = 64'hAAAAAAAAAAAAAAAA;
            defparam lcell_cntsel_int_0.dont_touch = "on";
            defparam lcell_cntsel_int_0.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_1 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(gnd),
                .dataf(gnd),
                .combout (cntsel_int[1]));
            defparam lcell_cntsel_int_1.lut_mask = 64'hCCCCCCCCCCCCCCCC;
            defparam lcell_cntsel_int_1.dont_touch = "on";
            defparam lcell_cntsel_int_1.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_2 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(gnd),
                .dataf(gnd),
                .combout (cntsel_int[2]));
            defparam lcell_cntsel_int_2.lut_mask = 64'hF0F0F0F0F0F0F0F0;
            defparam lcell_cntsel_int_2.dont_touch = "on";
            defparam lcell_cntsel_int_2.family = pll_type;
            altera_pll_dps_lcell_comb lcell_cntsel_int_3 (
                .dataa(cntsel_temp[0]),
                .datab(cntsel_temp[1]),
                .datac(cntsel_temp[2]),
                .datad(cntsel_temp[3]),
                .datae(gnd),
                .dataf(gnd),
                .combout (cntsel_int[3]));
            defparam lcell_cntsel_int_3.lut_mask = 64'hFF00FF00FF00FF00;
            defparam lcell_cntsel_int_3.dont_touch = "on";
            defparam lcell_cntsel_int_3.family = pll_type;
   
            twentynm_iopll_ip #(
                .reference_clock_frequency (reference_clock_frequency),
                .vco_frequency (pll_output_clk_frequency),
		        .compensation_mode(operation_mode),
				.output_clock_frequency_0(output_clock_frequency0),
				.output_clock_frequency_1(output_clock_frequency1),
				.output_clock_frequency_2(output_clock_frequency2),
				.output_clock_frequency_3(output_clock_frequency3),
				.output_clock_frequency_4(output_clock_frequency4),
				.output_clock_frequency_5(output_clock_frequency5),
				.output_clock_frequency_6(output_clock_frequency6),
				.output_clock_frequency_7(output_clock_frequency7),
				.output_clock_frequency_8(output_clock_frequency8),
				.phase_shift_0(phase_shift0),
				.phase_shift_1(phase_shift1),
				.phase_shift_2(phase_shift2),
				.phase_shift_3(phase_shift3),
				.phase_shift_4(phase_shift4),
				.phase_shift_5(phase_shift5),
				.phase_shift_6(phase_shift6),
				.phase_shift_7(phase_shift7),
				.phase_shift_8(phase_shift8),
				.duty_cycle_0(duty_cycle0),
				.duty_cycle_1(duty_cycle1),
				.duty_cycle_2(duty_cycle2),
				.duty_cycle_3(duty_cycle3),
				.duty_cycle_4(duty_cycle4),
				.duty_cycle_5(duty_cycle5),
				.duty_cycle_6(duty_cycle6),
				.duty_cycle_7(duty_cycle7),
				.duty_cycle_8(duty_cycle8),
				.pll_self_reset(pll_slf_rst),
				.bw_sel(pll_bw_sel),
				.pll_fbclk_mux_1(pll_fbclk_mux_1),
				.pll_fbclk_mux_2(pll_fbclk_mux_2),
				.pll_auto_clk_sw_en(pll_auto_clk_sw_en),
                .pll_clk_loss_sw_en(pll_clk_loss_sw_en),
                .pll_clk_sw_dly(pll_clk_sw_dly),
                .pll_manu_clk_sw_en(pll_manu_clk_sw_en),
				.pll_clkin_0_src((pll_clkin_0_src == "clk_0") ? "pll_clkin_0_src_ioclkin_0" : (pll_clkin_0_src == "clk_1") ? "pll_clkin_0_src_ioclkin_1" : (pll_clkin_0_src == "adj_pll_clk") ? "pll_clkin_0_src_refclkin" : "pll_clkin_0_src_coreclkin"),
				.pll_clkin_1_src((pll_clkin_1_src == "clk_1") ? "pll_clkin_1_src_ioclkin_1" : (pll_clkin_1_src == "clk_0") ? "pll_clkin_1_src_ioclkin_0" : (pll_clkin_1_src == "adj_pll_clk") ? "pll_clkin_1_src_refclkin" : "pll_clkin_1_src_coreclkin"),
				.pll_c0_out_en ((output_clock_frequency0 != "0 ps") ? "true" : "false"),
				.pll_c1_out_en ((output_clock_frequency1 != "0 ps") ? "true" : "false"),
				.pll_c2_out_en ((output_clock_frequency2 != "0 ps") ? "true" : "false"),
				.pll_c3_out_en ((output_clock_frequency3 != "0 ps") ? "true" : "false"),
				.pll_c4_out_en ((output_clock_frequency4 != "0 ps") ? "true" : "false"),
				.pll_c5_out_en ((output_clock_frequency5 != "0 ps") ? "true" : "false"),
				.pll_c6_out_en ((output_clock_frequency6 != "0 ps") ? "true" : "false"),
				.pll_c7_out_en ((output_clock_frequency7 != "0 ps") ? "true" : "false"),
				.pll_c8_out_en ((output_clock_frequency8 != "0 ps") ? "true" : "false"),
				.pll_c_counter_0_bypass_en (c_cnt_bypass_en0),
				.pll_c_counter_0_even_duty_en (c_cnt_odd_div_duty_en0),
				.pll_c_counter_0_high (c_cnt_hi_div0),
				.pll_c_counter_0_low (c_cnt_lo_div0),
				.pll_c_counter_0_ph_mux_prst (c_cnt_ph_mux_prst0),
				.pll_c_counter_0_prst (c_cnt_prst0),				
				.pll_c_counter_1_bypass_en (c_cnt_bypass_en1),
				.pll_c_counter_1_even_duty_en (c_cnt_odd_div_duty_en1),
				.pll_c_counter_1_high (c_cnt_hi_div1),
				.pll_c_counter_1_low (c_cnt_lo_div1),
				.pll_c_counter_1_ph_mux_prst (c_cnt_ph_mux_prst1),
				.pll_c_counter_1_prst (c_cnt_prst1),
				.pll_c_counter_2_bypass_en (c_cnt_bypass_en2),
				.pll_c_counter_2_even_duty_en (c_cnt_odd_div_duty_en2),
				.pll_c_counter_2_high (c_cnt_hi_div2),
				.pll_c_counter_2_low (c_cnt_lo_div2),
				.pll_c_counter_2_ph_mux_prst (c_cnt_ph_mux_prst2),
				.pll_c_counter_2_prst (c_cnt_prst2),
				.pll_c_counter_3_bypass_en (c_cnt_bypass_en3),
				.pll_c_counter_3_even_duty_en (c_cnt_odd_div_duty_en3),
				.pll_c_counter_3_high (c_cnt_hi_div3),
				.pll_c_counter_3_low (c_cnt_lo_div3),
				.pll_c_counter_3_ph_mux_prst (c_cnt_ph_mux_prst3),
				.pll_c_counter_3_prst (c_cnt_prst3),
				.pll_c_counter_4_bypass_en (c_cnt_bypass_en4),
				.pll_c_counter_4_even_duty_en (c_cnt_odd_div_duty_en4),
				.pll_c_counter_4_high (c_cnt_hi_div4),
				.pll_c_counter_4_low (c_cnt_lo_div4),
				.pll_c_counter_4_ph_mux_prst (c_cnt_ph_mux_prst4),
				.pll_c_counter_4_prst (c_cnt_prst4),
				.pll_c_counter_5_bypass_en (c_cnt_bypass_en5),
				.pll_c_counter_5_even_duty_en (c_cnt_odd_div_duty_en5),
				.pll_c_counter_5_high (c_cnt_hi_div5),
				.pll_c_counter_5_low (c_cnt_lo_div5),
				.pll_c_counter_5_ph_mux_prst (c_cnt_ph_mux_prst5),
				.pll_c_counter_5_prst (c_cnt_prst5),
				.pll_c_counter_6_bypass_en (c_cnt_bypass_en6),
				.pll_c_counter_6_even_duty_en (c_cnt_odd_div_duty_en6),
				.pll_c_counter_6_high (c_cnt_hi_div6),
				.pll_c_counter_6_low (c_cnt_lo_div6),
				.pll_c_counter_6_ph_mux_prst (c_cnt_ph_mux_prst6),
				.pll_c_counter_6_prst (c_cnt_prst6),
				.pll_c_counter_7_bypass_en (c_cnt_bypass_en7),
				.pll_c_counter_7_even_duty_en (c_cnt_odd_div_duty_en7),
				.pll_c_counter_7_high (c_cnt_hi_div7),
				.pll_c_counter_7_low (c_cnt_lo_div7),
				.pll_c_counter_7_ph_mux_prst (c_cnt_ph_mux_prst7),
				.pll_c_counter_7_prst (c_cnt_prst7),
				.pll_c_counter_8_bypass_en (c_cnt_bypass_en8),
				.pll_c_counter_8_even_duty_en (c_cnt_odd_div_duty_en8),
				.pll_c_counter_8_high (c_cnt_hi_div8),
				.pll_c_counter_8_low (c_cnt_lo_div8),
				.pll_c_counter_8_ph_mux_prst (c_cnt_ph_mux_prst8),
				.pll_c_counter_8_prst (c_cnt_prst8),
                .pll_enable ("true"),
				.pll_m_counter_bypass_en (m_cnt_bypass_en),
				.pll_m_counter_even_duty_en (m_cnt_odd_div_duty_en),
				.pll_m_counter_high(m_cnt_hi_div),
				.pll_m_counter_low(m_cnt_lo_div),
				.pll_n_counter_bypass_en(n_cnt_bypass_en),
				.pll_n_counter_high(n_cnt_hi_div),
				.pll_n_counter_low(n_cnt_lo_div),
                .pll_n_counter_odd_div_duty_en (n_cnt_odd_div_duty_en),
				.pll_vco_ph0_en ("true"),
				.pll_vco_ph1_en ("true"),
				.pll_vco_ph2_en ("true"),
				.pll_vco_ph3_en ("true"),
				.pll_vco_ph4_en ("true"),
				.pll_vco_ph5_en ("true"),
				.pll_vco_ph6_en ("true"),
				.pll_vco_ph7_en ("true"),
                .pll_powerdown_mode("false"),
				.pll_vccr_pd_en("true"),
				.pll_bwctrl(pll_bwctrl),
				.pll_cp_current_setting(pll_cp_current),
				.pll_extclk_0_cnt_src((operation_mode == "external" || operation_mode == "zdb") ? "pll_extclk_cnt_src_m_cnt": pll_extclk_0_cnt_src),
				.pll_extclk_0_enable("false"),
				.pll_extclk_1_cnt_src(pll_extclk_1_cnt_src),
				.pll_extclk_1_enable("false"),
				.pll_c0_extclk_dllout_en((pll_extclk_0_cnt_src == "pll_extclk_cnt_src_c_0_cnt" || pll_extclk_1_cnt_src == "pll_extclk_cnt_src_c_0_cnt") ? "true" : "false"),
				.pll_c1_extclk_dllout_en((pll_extclk_0_cnt_src == "pll_extclk_cnt_src_c_1_cnt" || pll_extclk_1_cnt_src == "pll_extclk_cnt_src_c_1_cnt") ? "true" : "false"),
				.pll_c2_extclk_dllout_en((pll_extclk_0_cnt_src == "pll_extclk_cnt_src_c_2_cnt" || pll_extclk_1_cnt_src == "pll_extclk_cnt_src_c_2_cnt") ? "true" : "false"),
				.pll_c3_extclk_dllout_en((pll_extclk_0_cnt_src == "pll_extclk_cnt_src_c_3_cnt" || pll_extclk_1_cnt_src == "pll_extclk_cnt_src_c_3_cnt") ? "true" : "false"),
				.clock_name_0 (clock_name_0),
				.clock_name_1 (clock_name_1),
				.clock_name_2 (clock_name_2),
				.clock_name_3 (clock_name_3),
				.clock_name_4 (clock_name_4),
				.clock_name_5 (clock_name_5),
				.clock_name_6 (clock_name_6),
				.clock_name_7 (clock_name_7),
				.clock_name_8 (clock_name_8),
				.clock_name_global_0 (clock_name_global_0),
				.clock_name_global_1 (clock_name_global_1),
				.clock_name_global_2 (clock_name_global_2),
				.clock_name_global_3 (clock_name_global_3),
				.clock_name_global_4 (clock_name_global_4),
				.clock_name_global_5 (clock_name_global_5),
				.clock_name_global_6 (clock_name_global_6),
				.clock_name_global_7 (clock_name_global_7),
				.clock_name_global_8 (clock_name_global_8)
			) twentynm_pll (		
				.clken(2'b00),
				.cnt_sel(pll_subtype != "General" ? (pll_subtype == "DPS" ? cntsel_int[3:0] : reconfig_to_pll[24:21]) : 4'b0),    // cnt_sel for IOPLL is 4 bits
				.core_refclk((pll_clkin_0_src == "coreclk") ? adjpllin : 1'b0),
				.dprio_clk(pll_subtype != "General" ? (pll_subtype == "DPS" ? scanclk : reconfig_to_pll[0]) : 1'b0),
				.dprio_rst_n(pll_subtype == "Reconfigurable" ? reconfig_to_pll[1] : ~rst),
				.dprio_address(pll_subtype == "Reconfigurable" ? reconfig_to_pll[12:4] : 9'b0),
                .read(pll_subtype == "Reconfigurable" ? reconfig_to_pll[2] : 1'b0),
                .write(pll_subtype == "Reconfigurable" ? reconfig_to_pll[3] : 1'b0),
                .writedata(pll_subtype == "Reconfigurable" ? reconfig_to_pll[20:13] : 8'b0),
				.dps_rst_n(~rst),
				.extswitch(extswitch),
				.fbclk_in((operation_mode == "normal" || operation_mode == "source_synchronous") ? feedback_clk : 1'b0),
				.fblvds_in((operation_mode == "lvds") ? lvds_fbclk : 1'b0),
				.num_phase_shifts(pll_subtype != "General" ? (pll_subtype == "DPS" ? num_phase_shifts : reconfig_to_pll[27:25]) : 3'b0),
				.pfden(1'b1),
				.phase_en(pll_subtype != "General" ? final_phase_en : 1'b0 ),
				.pipeline_global_en_n(),
				.pll_cascade_in((pll_clkin_0_src == "adj_pll_clk") ? adjpllin : 1'b0),
				.refclk({2'b0,refclk1, refclk}),
				.rst_n(~rst),
				.up_dn(pll_subtype != "General" ? (pll_subtype == "DPS" ? updn : reconfig_to_pll[28]) : 1'b0),
				.zdb_in((operation_mode == "external") ? fb_clkin : (operation_mode == "zdb") ? fb_out_clk : 1'b0),

				.block_select(),
				.clk0_bad(clkbad_wire[0]),
                .clk1_bad(clkbad_wire[1]),
				.clksel(activeclk_wire),
				.dll_output(),
				.extclk_dft(),
				.extclk_output({extclk_out[1], fboutclk_wire[0]}),
				.fbclk_out(feedback_clk),
				.fblvds_out(lvds_fbclk),
				.lf_reset(),
				.loaden(loaden),
				.lock(locked_wire[0]),
				.lvds_clk(lvds_clk),
				.outclk(divclk_wire),
				.phase_done(phase_done),
				.pll_cascade_out(cascade_out_wire[0]),
				.pll_pd(),
				.readdata(reconfig_from_pll[7:0]),
				.vcop_en(),
				.vcoph(phout_wire)
            );
                
            assign reconfig_from_pll[8] = locked_wire[0];
            assign reconfig_from_pll[9] = phase_done;
			assign extclk_out[0] = (operation_mode == "external" || operation_mode == "zdb") ? 1'b0 : fboutclk_wire[0];
			assign outclk_wire = divclk_wire;	
        end        
    end
    `endif
endgenerate

generate
    if (pll_type != "Arria 10")
    begin
		assign reconfig_from_pll = (pll_type == "General") ? 64'b0 : reconfig_from_pll_wire;

		if (pll_subtype == "DPS" || pll_subtype == "ReconfDPS")
		begin
			assign phase_done = reconfig_from_pll_wire[17];
		end
		else 
		begin
			assign phase_done = 1'b0;
		end
    end
	else 
	begin
		assign reconfig_from_pll[63:10] = (pll_type == "General") ? 54'b0 : reconfig_from_pll_wire[63:10];
		if (number_of_clocks != 1)
		begin
			assign cascade_out_wire[number_of_clocks-1:1] = 0;
		end
	end
endgenerate

generate 
    if (pll_type == "General")
    begin
        assign clkbad = 0;
        assign activeclk = 0;
		assign phout = 0;
		assign cascade_out = 0;
        assign lvds_clk = 0;
        assign loaden = 0;
		assign extclk_out = 0;
    end
    else 
    begin
        assign clkbad = clkbad_wire;
        assign activeclk = activeclk_wire;
		assign phout = phout_wire;
		assign cascade_out = cascade_out_wire;
    end
endgenerate

assign fboutclk = (operation_mode == "external feedback" || operation_mode == "zero delay buffer" || operation_mode == "external" || operation_mode == "zdb") ? fb_out_clk : fboutclk_wire[0]; 

assign outclk = outclk_wire;
//assign zdbfbclk = (operation_mode == "zero delay buffer" || operation_mode == "zdb") ? zdbfbclk : 1'b0;

// this is not correct for the old model
assign locked = locked_wire[0];

// synthesis translate off
generate
genvar j;
    if ( (pll_type == "General") && (use_old_model ==  0 || use_old_model == -1) && pll_frequency_parameter > 0 )
    begin : new_model
        generic_pll #(
                .reference_clock_frequency(reference_clock_frequency),
				.fractional_vco_multiplier(fractional_vco_multiplier),
                .sim_additional_refclk_cycles_to_lock(sim_additional_refclk_cycles_to_lock),
				.use_khz(using_khz),
                .output_clock_frequency( convert_to_mhz_string(pll_frequency_parameter,using_khz) ), 
                .duty_cycle(50), 
                .phase_shift("0 ps") )
                gpll (
                     .refclk(refclk),
                     .fbclk((operation_mode == "external feedback" || operation_mode == "external") ? fb_clkin : (operation_mode == "zero delay buffer" || operation_mode == "zdb") ? fb_out_clk : fboutclk_wire[0]),
                     .rst(rst),
                     .fboutclk(fboutclk_wire[0]),
                     .outclk(pll_clock),
                     .locked(locked_wire[0]),
		     //unused ports
		     .writerefclkdata(wire_to_nowhere_64[number_of_clocks][0]),
		     .writeoutclkdata(wire_to_nowhere_64[number_of_clocks][1]),
		     .writephaseshiftdata(wire_to_nowhere_64[number_of_clocks][2]),
		     .writedutycycledata(wire_to_nowhere_64[number_of_clocks][3]),
		     .readrefclkdata(wire_to_nowhere_64[number_of_clocks][4]),
		     .readoutclkdata(wire_to_nowhere_64[number_of_clocks][5]),
		     .readphaseshiftdata(wire_to_nowhere_64[number_of_clocks][6]),
		     .readdutycycledata(wire_to_nowhere_64[number_of_clocks][7])
                 );
        for (j = 0; j < number_of_clocks; j = j + 1)
        begin : output_counters
            always @(pll_clock or negedge locked_wire[0])
            begin
                if ( locked_wire[0] )
                begin
                    if ( count_up_to_C[j] == 0 )
                    begin
                        if (duty_cycle_parameter[j] != 50)
                        begin
                            // allign with the posedge
                            if ( pll_clock == 1'b1)
                            begin
                                outclk_reg[j] <= 1'b1;
                                outclk_reg[j] <= #(duty_cycle_hi[j]) 1'b0;
                                
                            end
                        end
                        else
                        begin
                            outclk_reg[j] <= ~outclk_reg[j];
                        end
                    end
                    if ( count_up_to_C[j] + 1 ==  counter_C[j] )
                        count_up_to_C[j] <= 0;
                    else
                        count_up_to_C[j] <= count_up_to_C[j] + 1;
                end
                else
                begin
                    count_up_to_C[j] <= 0;
                    outclk_reg[j] <= 1'b0;
                end
            end

            always @(outclk_reg[j])
            begin
                // The LHS is important to make the sim work.
                // It is like a transport line and this is the only way it can
                // work for phase > period.
                // However, it may make the simulation slower.
                outclk_reg_phase[j] <= #(phase_shift_value[j]) outclk_reg[j];
            end

            // guard by the phase
            // if no phase, change to 0 delta delay.
            assign outclk_wire[j] = (phase_shift_value[j] == 0) ? outclk_reg[j] :
                                    // do not propage an x value after lock
                                    ( outclk_reg_phase[j] === 1'bX && locked_wire[0] === 1'b1) ? 1'b0 :
                                    // phase shifted value
                                    outclk_reg_phase[j];
        
        end
        
    end
endgenerate 


// synthesis translate on


generate
    if (operation_mode == "external feedback" || operation_mode == "external")
    begin: fb_ibuf
    alt_inbuf #(.enable_bus_hold("NONE")) fb_ibuf (
                          .i(fbclk),
                          .o(fb_clkin)
                      );
    end
endgenerate

generate 
    if (operation_mode == "external feedback" || operation_mode == "external")
    begin: fb_obuf
    alt_outbuf #(.enable_bus_hold("NONE"))  fb_obuf (
                           .i(fboutclk_wire[0]),
                           .o(fb_out_clk)
                       );
    end
endgenerate

generate
    if (operation_mode == "zero delay buffer" || operation_mode == "zdb")
    begin: fb_iobuf
    alt_iobuf #(.enable_bus_hold("NONE"))  fb_iobuf (
                           .i(fboutclk_wire[0]),
                           .oe(1'b1),
                           .io(zdbfbclk),
                           .o(fb_out_clk)
                       );
    end
    else begin
       assign zdbfbclk = 0;
    end
endgenerate

endmodule
module dps_extra_kick (
    input   wire        clk,
    input   wire        reset,
    input   wire        phase_done,
    input   wire        usr_phase_en,
    //output
    output  wire        phase_en);

    reg [3:0]       dps_current_state;
    reg [3:0]       dps_next_state;
    reg             int_phase_en;
    localparam PHASE_DONE_LOW_0 = 4'd0, PHASE_DONE_LOW_1 = 4'd1, PHASE_DONE_LOW_2 = 4'd2, PHASE_DONE_LOW_3 = 4'd3, PHASE_DONE_LOW_4 = 4'd4, PHASE_DONE_HIGH = 4'd5; 
    localparam PHASE_EN_WAIT_COUNTER = 5'd0;

    //fsm
    //always block controlling the state regs
    always @(posedge clk)
    begin
        if (reset)
        begin
            dps_current_state <= PHASE_DONE_HIGH;
        end
        else
        begin
            dps_current_state <= dps_next_state;
        end
    end
 
    always @(*)
    begin
        int_phase_en = 0;
        dps_next_state = PHASE_DONE_HIGH;
        case (dps_current_state)
            PHASE_DONE_HIGH:
            begin
                if (phase_done == 1'b1)
                    dps_next_state = PHASE_DONE_HIGH;
                else 
                    dps_next_state = PHASE_DONE_LOW_0;
            end
            PHASE_DONE_LOW_0:
            begin
                if (phase_done == 1'b1)
                    dps_next_state = PHASE_DONE_HIGH;
                else 
                    dps_next_state = PHASE_DONE_LOW_1;
            end
            PHASE_DONE_LOW_1:
            begin
                if (phase_done == 1'b1)
                    dps_next_state = PHASE_DONE_HIGH;
                else 
                    dps_next_state = PHASE_DONE_LOW_2;
            end
            PHASE_DONE_LOW_2:
            begin
                if (phase_done == 1'b1)
                    dps_next_state = PHASE_DONE_HIGH;
                else 
                    dps_next_state = PHASE_DONE_LOW_3;
            end
            PHASE_DONE_LOW_3:
            begin
                if (phase_done == 1'b1)
                    dps_next_state = PHASE_DONE_HIGH;
                else 
                    dps_next_state = PHASE_DONE_LOW_4;
            end
            PHASE_DONE_LOW_4:
            begin
                if (phase_done == 1'b0)
                    int_phase_en = 1'b1;
                dps_next_state = PHASE_DONE_HIGH;
            end
            default: dps_next_state = 4'bxxxx;
        endcase
    end
    assign phase_en = (usr_phase_en === 1'bz) ? 1'bz : (usr_phase_en || int_phase_en);
endmodule
module dprio_init (
    input               clk,
    input               reset_n,

    output      [ 5:0]  dprio_address,
    output      [ 1:0]  dprio_byteen,
    output              dprio_write,
    output      [15:0]  dprio_writedata,

    output  reg         atpgmode,
    output  reg         mdio_dis,
    output  reg         scanen,
    output  reg         ser_shift_load,
    output  reg         dprio_init_done
);

    reg [1:0] rst_n = 2'b00;
    reg [6:0] count = 7'd0;
    reg init_done_forever;

    // Internal versions of control signals
    wire  int_mdio_dis;
    wire  int_ser_shift_load;
    wire  int_dprio_init_done;
    wire  int_atpgmode;
    wire  int_scanen;


    assign  dprio_address   = count[6] ? 5'b0 : count[5:0] ;
    assign  dprio_byteen    = count[6] ? 2'b0 : 2'b11;      // always enabled
    assign  dprio_write     = ~count[6] & reset_n ;  // write for first 64 cycles
    assign  dprio_writedata = 16'd0;

    assign  int_ser_shift_load  = count[6] ? |count[2:1]  : 1'b1; 
    assign  int_mdio_dis        = count[6] ? ~count[2]    : 1'b1;
    assign  int_dprio_init_done = ~init_done_forever ? (count[6] ? &count[2:0]  : 1'b0)
                                                    : 1'b1;
    assign  int_atpgmode        = 0;
    assign  int_scanen          = 0;


    // reset synch.
    always @(posedge clk or negedge reset_n)
        if(!reset_n)  rst_n <= 2'b00;
        else          rst_n <= {rst_n[0],1'b1};

    // counter
    always @(posedge clk)
    begin
        if (count[6] && &count[1:0])
            init_done_forever <= 1'b1;
    end
    always @(posedge clk or negedge rst_n[1])
    begin
        if(!rst_n[1])
        begin
            count <= 7'd0;
        end
        else if(~int_dprio_init_done) 
        begin
            count <= count + 7'd1;
        end
        else
        begin
            count <= count;
        end
    end

    // outputs
    always @(posedge clk) begin
        mdio_dis        <= int_mdio_dis;
        ser_shift_load  <= int_ser_shift_load;
        dprio_init_done <= int_dprio_init_done;
        atpgmode        <= int_atpgmode;
        scanen          <= int_scanen;
    end

endmodule

module dps_pulse_gen (
    input  wire clk,            // the DPS clock
    input  wire rst,            // active high reset
    input  wire user_phase_en,  // the user's phase_en signal
    output reg  phase_en        // the phase_en signal for the IOPLL atom 
 );
 
    //-------------------------------------------------------------------------
    // States
    localparam IDLE        = 0,  // Idle state: user_phase_en = 0, phase_en = 0
               PULSE       = 1,  // Activate state: phase_en = 1
               WAIT        = 2;  // Wait for user_phase_en to go low

    //-------------------------------------------------------------------------
    // FSM current and next states
    reg [1:0] state, next;     
    
    // State update
    always @(posedge clk) begin
        if (rst)    state <= IDLE;
        else        state <= next; 
    end  

    //-------------------------------------------------------------------------    
    // Next-state and output logic
    always @(*) begin
        next     = IDLE;  // Default next state 
        phase_en = 1'b0;  // Default output
        
        case (state)
            IDLE :  begin
                        if (user_phase_en)  next = PULSE;
                        else                next = IDLE;
                    end     
                         
            PULSE : begin
                        phase_en = 1'b1;
                        next     = WAIT;
                    end
                         
            WAIT :  begin         
                        if (~user_phase_en) next = IDLE;
                        else                next = WAIT;                  
                    end  
        endcase
    end
     
 endmodule


