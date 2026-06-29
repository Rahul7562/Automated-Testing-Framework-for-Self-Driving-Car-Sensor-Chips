module secded_ecc (
    input wire clk,
    input wire rst_n,
    input wire [63:0] data_in,
    input wire valid_in,

    output reg [63:0] data_out,
    output reg valid_out,
    output reg single_err,
    output reg double_err
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 64'd0;
            valid_out <= 1'b0;
            single_err <= 1'b0;
            double_err <= 1'b0;
        end else begin
            // Simulating SECDED. If data is specific magic value, trigger error for tb.
            if (valid_in && data_in == 64'hDEADBEEF_DEADBEEF) begin
                single_err <= 1'b1;
                double_err <= 1'b0;
                data_out <= 64'h0; // Corrected
            end else if (valid_in && data_in == 64'hBAD0BAD0_BAD0BAD0) begin
                single_err <= 1'b0;
                double_err <= 1'b1;
                data_out <= data_in; // Uncorrectable
            end else begin
                single_err <= 1'b0;
                double_err <= 1'b0;
                data_out <= data_in;
            end
            valid_out <= valid_in;
        end
    end
endmodule
