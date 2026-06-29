module axis_ingestion (
    input wire aclk,
    input wire aresetn,
    input wire [63:0] s_axis_tdata,
    input wire s_axis_tvalid,
    output wire s_axis_tready,

    output reg [63:0] m_data,
    output reg m_valid,
    input wire m_ready
);
    reg [63:0] data_reg;
    reg valid_reg;

    assign s_axis_tready = ~valid_reg | m_ready;

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            valid_reg <= 1'b0;
            data_reg <= 64'd0;
        end else begin
            if (s_axis_tready && s_axis_tvalid) begin
                data_reg <= s_axis_tdata;
                valid_reg <= 1'b1;
            end else if (m_ready) begin
                valid_reg <= 1'b0;
            end
        end
    end

    always @(*) begin
        m_data = data_reg;
        m_valid = valid_reg;
    end
endmodule
