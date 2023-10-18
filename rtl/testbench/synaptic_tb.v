`default_nettype none

module tb_synaptic;

// synaptic Parameters
parameter N        = 128     ;
parameter WID      = 8       ;

// synaptic Inputs
reg   clk;
reg   rst_n;
reg   [31:0]  sparse_bits;
reg   [0:0]  ipt_valid;

// synaptic Outputs
wire  ipt_ready;
wire  opt_valid;
reg  opt_ready;
wire  [11:0]  opt_syn;

synaptic #(
    .N   ( 256 ),
    .WID ( 8   ))
 u_synaptic (
    .clk                     ( clk           ),
    .rst_n                   ( rst_n         ),
    .sparse_bits             ( sparse_bits   ),
    .ipt_valid               ( ipt_valid     ),

    .ipt_ready               ( ipt_ready     ),
    .opt_valid               ( opt_valid     ),
    .opt_ready               ( opt_ready     ),
    .opt_syn                 ( opt_syn       )
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    $dumpfile("tb_synaptic.vcd");
    $dumpvars(0, tb_synaptic);
end

integer input_neurons[15:0];
integer i;
reg [127:0] input_bits;
//sum = 779;
initial begin
    input_neurons[0]=9;
    input_neurons[1]=12;
    input_neurons[2]=22;
    input_neurons[3]=26;
    input_neurons[4]=30;
    input_neurons[5]=41;
    input_neurons[6]=44;
    input_neurons[7]=53;
    input_neurons[8]=55;
    input_neurons[9]=59;
    input_neurons[10]=62;
    input_neurons[11]=63;
    input_neurons[12]=68;
    input_neurons[13]=76;
    input_neurons[14]=79;
    input_neurons[15]=80;
    input_bits = 128'b0;
    for (i = 0; i<128; i=i+1) begin
        input_bits[input_neurons[i]] = 1;
    end
end

initial begin
    #1 rst_n<=1'bx;clk<=1'bx;
    // sparse_bits <= $random;
    ipt_valid <= 1'b0;
    opt_ready <= 1'b1;
    #(CLK_PERIOD*3) rst_n<=1;
    #(CLK_PERIOD*3) rst_n<=0;clk<=0;
    repeat(5) @(posedge clk);
    rst_n<=1;
    @(posedge clk);
    repeat(2) @(posedge clk);
    ipt_valid = 1'b1;
    sparse_bits = input_bits[31:0];
    input_bits = input_bits >> 32;
    repeat(1000) @(posedge clk) begin
        if(ipt_ready&ipt_valid)begin
            sparse_bits = input_bits[31:0];
            input_bits = input_bits >> 32;
            ipt_valid <= 1'b1;
        end
        opt_ready <= ($random%50+50) > 10;
    end
    ipt_valid = 0;
    repeat(10) @(posedge clk);
    $finish(2);
end

endmodule
`default_nettype wire