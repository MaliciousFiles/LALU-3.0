// DON'T INIT WITH THE SAME FILE; FREEZES IVERILOG
module RAM #(parameter widthad = 16, parameter initfile = "UNUSED") (
    input                   clk,

    input [widthad-1:0]     address_a,
    input                   wren_a,
    input [31:0]            data_a,
    input                   rden_a,
    output [31:0]           q_a,

    input [widthad-1:0]     address_b,
    input                   wren_b,
    input [31:0]            data_b,
    input                   rden_b,
    output [31:0]           q_b);

    altsyncram ram (
        .clock0(clk),

        .address_a(address_a),
        .wren_a(wren_a),
        .data_a(data_a),
        .rden_a(rden_a),
        .q_a(q_a),

        .address_b(address_b),
        .wren_b(wren_b),
        .data_b(data_b),
        .rden_b(rden_b),
        .q_b(q_b),

        .aclr0(1'b0),
        .aclr1(1'b0),
        .addressstall_a(1'b0),
        .addressstall_b(1'b0),
        .byteena_a(1'b1),
        .byteena_b(1'b1),
        .clock1(1'b1),
        .clocken0(1'b1),
        .clocken1(1'b1),
        .clocken2(1'b1),
        .clocken3(1'b1),
        .eccstatus());

    defparam
        ram.init_file = initfile,
//        ram.lpm_hint = "ENABLE_RUNTIME_MOD=yes",
        ram.address_reg_b = "CLOCK0",
        ram.clock_enable_input_a = "BYPASS",
        ram.clock_enable_input_b = "BYPASS",
        ram.clock_enable_output_a = "BYPASS",
        ram.clock_enable_output_b = "BYPASS",
        ram.indata_reg_b = "CLOCK0",
        ram.intended_device_family = "Cyclone V",
        ram.lpm_type = "altsyncram",
        ram.numwords_a = 1<<widthad,
        ram.numwords_b = 1<<widthad,
        ram.operation_mode = "BIDIR_DUAL_PORT",
        ram.outdata_aclr_a = "NONE",
        ram.outdata_aclr_b = "NONE",
        ram.outdata_reg_a = "UNREGISTERED",
        ram.outdata_reg_b = "UNREGISTERED",
        ram.power_up_uninitialized = "FALSE",
        ram.ram_block_type = "M10K",
        ram.read_during_write_mode_mixed_ports = "OLD_DATA",
        ram.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
        ram.read_during_write_mode_port_b = "NEW_DATA_NO_NBE_READ",
        ram.widthad_a = widthad,
        ram.widthad_b = widthad,
        ram.width_a = 32,
        ram.width_b = 32,
        ram.width_byteena_a = 1,
        ram.width_byteena_b = 1,
        ram.wrcontrol_wraddress_reg_b = "CLOCK0";

endmodule