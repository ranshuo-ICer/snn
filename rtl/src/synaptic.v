module synaptic #(
    parameter N = 128,
    parameter M = 64,
    parameter P = 2,
    parameter WID = 8
)(
    input clk, rst_n,

    input [31:0] sparse_bits,
    input [0:0] ipt_valid,
    output ipt_ready,

    output opt_valid,
    input opt_ready,
    output [11:0] opt_syn
);

// idx_enc Outputs
wire  [0:0]  idx_enc_ipt_ready;
wire  [5:0]  idx_enc_enc;
wire  [0:0]  idx_enc_opt_valid;
wire  [0:0]  idx_enc_opt_ready;

idx_enc_32  u_idx_enc (
    .clk                     ( clk           ),
    .rst_n                   ( rst_n         ),
    .ipt_ready               ( ipt_ready     ),
    .ipt_valid               ( ipt_valid     ),
    .sparse_bits             ( sparse_bits   ),
    
    .enc                     ( idx_enc_enc           ),
    .opt_ready               ( idx_enc_opt_ready     ),
    .opt_valid               ( idx_enc_opt_valid     )
);


synaptic_accum #(
    .N       ( N      ),
    .WID     ( WID        ))
 u_synaptic_accum (
    .clk                     ( clk         ),
    .rst_n                   ( rst_n       ),
    .enc                     ( idx_enc_enc         ),
    .ipt_valid               ( idx_enc_opt_valid   ),
    .ipt_ready               ( idx_enc_opt_ready   ),

    .opt_ready               ( opt_ready),
    .opt_valid               ( opt_valid   ),
    .opt_syn                 ( opt_syn     )
);

endmodule