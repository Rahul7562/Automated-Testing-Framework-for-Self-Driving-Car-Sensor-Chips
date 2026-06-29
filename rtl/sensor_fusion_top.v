module sensor_fusion_top (
    input wire aclk,
    input wire aresetn,

    // AXI4-Stream Input
    input wire [63:0] s_axis_tdata,
    input wire s_axis_tvalid,
    output wire s_axis_tready,

    // Processed Output
    output wire [63:0] m_axis_tdata,
    output wire m_axis_tvalid,

    // Safety Telemetry
    output wire system_halt,
    output wire [31:0] err_count
);

    wire [63:0] ing_data;
    wire ing_valid;

    axis_ingestion ingestion_inst (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .m_data(ing_data),
        .m_valid(ing_valid),
        .m_ready(1'b1)
    );

    wire [63:0] sec_data;
    wire sec_valid;
    wire single_err;
    wire double_err;

    secded_ecc ecc_inst (
        .clk(aclk),
        .rst_n(aresetn),
        .data_in(ing_data),
        .valid_in(ing_valid),
        .data_out(sec_data),
        .valid_out(sec_valid),
        .single_err(single_err),
        .double_err(double_err)
    );

    wire [63:0] ekf_data;
    wire ekf_valid;

    ekf_engine ekf_inst (
        .clk(aclk),
        .rst_n(aresetn),
        .meas_in(sec_data),
        .valid_in(sec_valid),
        .state_out(ekf_data),
        .valid_out(ekf_valid)
    );

    matrix_inverter inv_inst (
        .clk(aclk),
        .rst_n(aresetn),
        .mat_in(ekf_data),
        .valid_in(ekf_valid),
        .mat_out(m_axis_tdata),
        .valid_out(m_axis_tvalid)
    );

    safety_island safety_inst (
        .clk(aclk),
        .rst_n(aresetn),
        .single_err(single_err),
        .double_err(double_err),
        .system_halt(system_halt),
        .err_count(err_count)
    );

endmodule
