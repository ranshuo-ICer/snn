
`default_nettype none

module tb_lif;
// lif Parameters
parameter W_WID  = 8;
parameter W_NUM  = 4;
parameter TAU    = 3;
parameter VTH    = 50;
parameter VRES   = 0;

// lif Inputs
reg   clk;
reg   rst_n;
reg   [7:0]  ir;

// lif Outputs
wire  o_spike;

lif #(
    .W_WID ( W_WID ),
    .W_NUM ( W_NUM ),
    .TAU   ( TAU ),
    .VTH   ( VTH ),
    .VRES  ( VRES ))
 u_lif (
    .clk                     ( clk       ),
    .rst_n                   ( rst_n     ),
    .ir                      ( ir        ),

    .o_spike                 ( o_spike   )
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    $dumpfile("tb_lif.vcd");
    $dumpvars(0, tb_lif);
end

integer i;
initial begin
    #1 rst_n<=1'bx;clk<=1'bx;ir <= 0;
    #(CLK_PERIOD*3) rst_n<=1;
    #(CLK_PERIOD*3) rst_n<=0;clk<=0;
    repeat(5) @(posedge clk);
    rst_n<=1;
    @(posedge clk);
    repeat(2) @(posedge clk);
    for (i = 0; i<1000; i=i+1) begin
        #(CLK_PERIOD)
        ir <= $random%50+50;
    end
    $finish(2);
end

endmodule
`default_nettype wire  