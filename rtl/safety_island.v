module safety_island (
    input wire clk,
    input wire rst_n,
    input wire single_err,
    input wire double_err,
    output reg system_halt,
    output reg [31:0] err_count
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            system_halt <= 1'b0;
            err_count <= 32'd0;
        end else begin
            if (single_err) err_count <= err_count + 1;
            if (double_err) system_halt <= 1'b1;
        end
    end
endmodule
