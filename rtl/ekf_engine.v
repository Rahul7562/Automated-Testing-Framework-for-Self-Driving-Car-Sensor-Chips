module ekf_engine (
    input wire clk,
    input wire rst_n,
    input wire [63:0] meas_in,
    input wire valid_in,

    output reg [63:0] state_out,
    output reg valid_out
);
    reg signed [31:0] state_x;
    reg signed [31:0] state_y;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_x <= 32'd0;
            state_y <= 32'd0;
            state_out <= 64'd0;
            valid_out <= 1'b0;
        end else if (valid_in) begin
            // Update state internally
            state_x <= state_x + (($signed(meas_in[31:0]) - state_x) >>> 1);
            state_y <= state_y + (($signed(meas_in[63:32]) - state_y) >>> 1);

            // Assign out the new state directly to avoid 1 clock cycle delay mismatch with internal register
            state_out <= {
                (state_y + (($signed(meas_in[63:32]) - state_y) >>> 1)),
                (state_x + (($signed(meas_in[31:0]) - state_x) >>> 1))
            };
            valid_out <= 1'b1;
        end else begin
            valid_out <= 1'b0;
        end
    end
endmodule
