// `include "adder.v"
`default_nettype none

module tb_adder;
reg clk;
reg rst_n;
reg [3:0] a,b;
wire [3:0] s;
adder adder_u
(
    .rst_n (rst_n),
    .clk (clk),
    .a(a),
    .b(b),
    .s(s)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    $dumpfile("tb_adder.vcd");
    $dumpvars(0, tb_adder);
end

initial begin
    #1 rst_n<=1'bx;clk<=1'bx;
    a = 3;
    b = 4;
    #(CLK_PERIOD*3) rst_n<=1;
    #(CLK_PERIOD*3) rst_n<=0;clk<=0;
    repeat(5) @(posedge clk);
    rst_n<=1;
    @(posedge clk);
    repeat(2) @(posedge clk);
    
    $finish(2);
end

endmodule
`default_nettype wire  