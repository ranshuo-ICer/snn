module synaptic_array #(
    parameter P = 64,
    parameter SYNWID = 8,
    parameter MWID    = 12
) (
    input clk,
    input rst_n,

    input ipt0_valid,
    output ipt0_ready,
    input [31:0] sparse_bits0,

    input ipt1_valid,
    output ipt1_ready,
    input [31:0] sparse_bits1,

    output [P*MWID-1:0] syn_opt,
    output syn_opt_valid,
    input syn_opt_ready 

);
    
localparam DEEPTH   = 128          ;
localparam ADDRWID  = $clog2(DEEPTH);
localparam WIDTH    = P*SYNWID         ;

// reduce_accum_2 Outputs
wire                reduce_accum_syn1_ready;
wire                reduce_accum_syn2_ready;


// synaptic_core Outputs
wire                synaptic_core_0_opt_valid;
wire  [P*MWID-1:0]  synaptic_core_0_opt_acc;

synaptic_core #(
    .P      ( P ),
    .SYNWID ( SYNWID  ),
    .MWID   ( MWID ),
    .DEEPTH (DEEPTH))
 u_synaptic_core_0 (
    .clk                     ( clk           ),
    .rst_n                   ( rst_n         ),
    .ipt_valid               ( ipt0_valid     ),
    .ipt_ready               ( ipt0_ready     ),
    .sparse_bits             ( sparse_bits0   ),
    
    .opt_valid               ( synaptic_core_0_opt_valid     ),
    .opt_ready               ( reduce_accum_syn1_ready     ),
    .opt_acc                 ( synaptic_core_0_opt_acc       )
);

// synaptic_core Outputs
wire                synaptic_core_1_opt_valid;
wire  [P*MWID-1:0]  synaptic_core_1_opt_acc;

synaptic_core #(
    .P      ( P ),
    .SYNWID ( SYNWID  ),
    .MWID   ( MWID ),
    .DEEPTH (DEEPTH))
 u_synaptic_core_1 (
    .clk                     ( clk           ),
    .rst_n                   ( rst_n         ),
    .ipt_valid               ( ipt1_valid     ),
    .ipt_ready               ( ipt1_ready     ),
    .sparse_bits             ( sparse_bits1   ),
    
    .opt_valid               ( synaptic_core_1_opt_valid     ),
    .opt_ready               ( reduce_accum_syn2_ready     ),
    .opt_acc                 ( synaptic_core_1_opt_acc       )
);

     


reduce_accum #(
    .P(P),
    .MWID ( MWID ))
u_reduce_accum (
    .clk                     ( clk          ),
    .rst_n                   ( rst_n        ),
    .syn1                    ( synaptic_core_0_opt_acc         ),
    .syn1_valid              ( synaptic_core_0_opt_valid   ),
    .syn1_ready              ( reduce_accum_syn1_ready   ),

    .syn2                    ( synaptic_core_1_opt_acc         ),
    .syn2_valid              ( synaptic_core_1_opt_valid   ),
    .syn2_ready              ( reduce_accum_syn2_ready   ),
    
    .syn                     ( syn_opt          ),
    .syn_valid               ( syn_opt_valid    ),
    .syn_ready               ( syn_opt_ready    )
);

        
endmodule