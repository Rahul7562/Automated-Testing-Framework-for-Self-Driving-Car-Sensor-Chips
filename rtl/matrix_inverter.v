module matrix_inverter (
    input wire clk,
    input wire rst_n,
    input wire [63:0] mat_in,
    input wire valid_in,
    output reg [63:0] mat_out,
    output reg valid_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mat_out <= 64'd0;
            valid_out <= 1'b0;
        end else begin
            mat_out <= mat_in;
            valid_out <= valid_in;
        end
    end
endmodule
