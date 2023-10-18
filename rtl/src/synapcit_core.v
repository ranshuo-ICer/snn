module synaptic_core #(
    parameter P = 64,
    parameter SYNWID = 8,
    parameter MWID = 12,
    parameter DEEPTH   = 512
) (
    input clk,
    input rst_n,

    input ipt_valid,
    output ipt_ready,
    input [31:0] sparse_bits,

    output opt_valid,
    input opt_ready,
    output [P*MWID-1:0] opt_acc
);
    

localparam ADDRWID  = $clog2(DEEPTH);
localparam WIDTH    = P*SYNWID         ;

// weight ram output
wire [WIDTH-1:0]    wram_rdata ;


// idx_enc_32 Outputs
wire  [5:0]  enc_opt;
wire  [0:0]  enc_opt_valid;

// synaptic_ctrl Outputs
wire  synaptic_ctrl_ipt_ready;
wire  synaptic_ctrl_syn_mem_ren;
wire  [ADDRWID-1:0] synaptic_ctrl_syn_mem_raddr;
wire  synaptic_ctrl_acc_clr;
wire  synaptic_ctrl_acc_valid;


idx_enc_32  u_idx_enc_32 (
    .clk                     ( clk           ),
    .rst_n                   ( rst_n         ),
    .ipt_valid               ( ipt_valid     ),
    .ipt_ready               ( ipt_ready     ),
    .sparse_bits             ( sparse_bits   ),
    
    .enc                     ( enc_opt           ),
    .opt_ready               ( synaptic_ctrl_ipt_ready     ),
    .opt_valid               ( enc_opt_valid     )
);

synaptic_ctrl #(
    .N    ( DEEPTH ),
    .WID  ( SYNWID   ),
    .MWID ( MWID  ))
 u_synaptic_ctrl (
    .clk                     ( clk             ),
    .rst_n                   ( rst_n           ),
    .enc                     ( enc_opt             ),
    .ipt_valid               ( enc_opt_valid       ),
    
    .ipt_ready               ( synaptic_ctrl_ipt_ready       ),
    .syn_mem_ren             ( synaptic_ctrl_syn_mem_ren     ),
    .syn_mem_raddr           ( synaptic_ctrl_syn_mem_raddr   ),
    .acc_clr                 ( synaptic_ctrl_acc_clr         ),
    .acc_valid               ( synaptic_ctrl_acc_valid       ),
    .opt_valid               ( opt_valid       ),
    .opt_ready               ( opt_ready       )
);


weight_ram #(
    .DEEPTH  ( DEEPTH            ),
    .ADDRWID ( ADDRWID ),
    .P         (P),
    .WIDTH   ( P*SYNWID          ))
 u_weight_ram (
    .clk                     ( clk     ),
    .rst_n                   ( rst_n   ),
    .raddr                   ( synaptic_ctrl_syn_mem_raddr   ),
    .ren                     ( synaptic_ctrl_syn_mem_ren     ),

    .rdata                   ( wram_rdata   )
);

generate
    genvar i;
    for (i = 0; i<P; i=i+1) begin
        accumulator #(
            .WID ( MWID ),
            .SYNWID(SYNWID))
        u_accumulator (
            .clk                     ( clk     ),
            .rst_n                   ( rst_n   ),
            .clr                     ( synaptic_ctrl_acc_clr     ),
            .valid                   ( synaptic_ctrl_acc_valid   ),
            .data                    ( wram_rdata[i*SYNWID+:SYNWID]    ),

            .acc                     ( opt_acc[i*MWID+:MWID]     )
        );
    end
endgenerate

endmodule