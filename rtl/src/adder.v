module adder (
    input clk, rst_n,
    input [3:0] a, b,

    output reg [3:0] s
);
    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            s <= 0;
        end else begin
            s <= a + b;
        end
    end
endmodule