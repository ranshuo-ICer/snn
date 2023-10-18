`timescale  1ns / 1ps

module tb_synaptic_array;

// synaptic_array Parameters
parameter PERIOD  = 10;
parameter P       = 1;
parameter SYNWID  = 8 ;
parameter MWID    = 16;

// synaptic_array Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   ipt0_valid                           = 0 ;
reg   [31:0]  sparse_bits0                 = 0 ;
reg   ipt1_valid                           = 0 ;
reg   [31:0]  sparse_bits1                 = 0 ;
reg   syn_opt_ready                        = 0 ;

// synaptic_array Outputs
wire  ipt0_ready                           ;
wire  ipt1_ready                           ;
wire  [P*MWID-1:0]  syn_opt                ;
wire  syn_opt_valid                        ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
    #(PERIOD*2) rst_n  =  0;
    #(PERIOD*4) rst_n  =  1; 
end

synaptic_array #(
    .P      ( P      ),
    .SYNWID ( SYNWID ),
    .MWID   ( MWID   ))
 u_synaptic_array (
    .clk                     ( clk                         ),
    .rst_n                   ( rst_n                       ),
    .ipt0_valid              ( ipt0_valid                  ),
    .sparse_bits0            ( sparse_bits0   [31:0]       ),
    .ipt1_valid              ( ipt1_valid                  ),
    .sparse_bits1            ( sparse_bits1   [31:0]       ),
    
    .ipt0_ready              ( ipt0_ready                  ),
    .ipt1_ready              ( ipt1_ready                  ),
    .syn_opt                 ( syn_opt        [P*MWID-1:0] ),
    .syn_opt_ready           ( syn_opt_ready               ),
    .syn_opt_valid           ( syn_opt_valid               )
);
integer i;
initial
begin
    ipt0_valid = 0;
    ipt1_valid = 0;
    syn_opt_ready = 1;
    #(PERIOD*8);
    ipt0_valid = 1;
    get_random_bits(4, sparse_bits0);
    ipt1_valid = 1;
    get_random_bits(4, sparse_bits1);
    for (i = 0; i<1000; i=i+1) begin
        if (ipt0_ready&ipt0_valid) begin
            ipt0_valid = 1;
            get_random_bits(4, sparse_bits0);
        end
        if (ipt1_ready&ipt1_valid) begin
            ipt1_valid = 1;
            get_random_bits(4, sparse_bits1);
        end
        #(PERIOD);
    end
    $finish;
end

initial begin
    $dumpfile("tb_synaptic_array.vcd");
    $dumpvars(0, tb_synaptic_array);
end

task automatic get_random_bits;
    input integer n;
    output reg [31:0] random_bits;
    integer i;
    integer idx;

    begin
        random_bits = 32'h00000000; // 初始化为全0
        for (i=0; i<n; i=i+1) begin
            idx = $random % 32; // 获取一个随机的索引
            random_bits[idx] = 1'b1; // 将索引位置的位设置为1
        end
    end
endtask


endmodule