`default_nettype none

module tb_idx_enc;
// idx_enc Inputs
reg   clk;
reg   rst_n;
reg   ipt_valid;
reg   [7:0]  sparse_bits;

// idx_enc Outputs
wire  [0:0]  ipt_ready;
wire  [3:0]  enc;
wire  [0:0]  opt_valid;
reg   opt_ready;

idx_enc  u_idx_enc (
    .clk                     ( clk           ),
    .rst_n                   ( rst_n         ),
    .ipt_valid               ( ipt_valid     ),
    .sparse_bits             ( sparse_bits   ),

    .ipt_ready               ( ipt_ready     ),
    .enc                     ( enc           ),
    .opt_valid               ( opt_valid     ),
    .opt_ready               ( opt_ready     )
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    $dumpfile("tb_idx_enc.vcd");
    $dumpvars(0, tb_idx_enc);
end

initial begin
    #1 rst_n<=1'bx;clk<=1'bx;
    sparse_bits <= $random;
    ipt_valid <= 1'b0;
    opt_ready <= 1'b1;
    #(CLK_PERIOD*3) rst_n<=1;
    #(CLK_PERIOD*3) rst_n<=0;clk<=0;
    repeat(5) @(posedge clk);
    rst_n<=1;
    @(posedge clk);
    repeat(2) @(posedge clk);
    ipt_valid <= 1'b1;
    repeat(100) @(posedge clk) begin
        if(ipt_ready&ipt_valid)begin
            sparse_bits <= $random;
            ipt_valid <= 1'b1;
        end
        opt_ready <= ($random%50+50) > 10;
    end
    $finish(2);
end

endmodule
`default_nettype wire