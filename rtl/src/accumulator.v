module accumulator#(
    parameter WID = 12,
    parameter SYNWID = 8
) (
    input clk,
    input rst_n,

    input clr,
    input valid,
    input [SYNWID-1:0] data,

    output reg [WID-1:0] acc
);
    
always @(posedge clk , negedge rst_n) begin
    if (rst_n == 1'b0) begin
        acc <= 0;
    end else begin
        if (clr) begin
            acc <= 0;
        end else begin
            if (valid) begin
                acc <= acc + data;
            end
        end
    end
end

endmodule