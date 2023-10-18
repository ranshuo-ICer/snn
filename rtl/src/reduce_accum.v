module reduce_accum#(
    parameter P = 64,
    parameter MWID = 12
)(
    input clk,
    input rst_n,

    input [P*MWID-1:0] syn1,
    input syn1_valid,
    output syn1_ready,

    input [P*MWID-1:0] syn2,
    input syn2_valid,
    output syn2_ready,

    output [P*MWID-1:0] syn,
    output syn_valid,
    input syn_ready
);
    integer i;
    reg [P*MWID-1:0] sum;
    reg full_r;

    wire wen_r = !full_r|syn_ready; // writable when empty and opt_ready
    always @(posedge clk , negedge rst_n) begin
        if(rst_n == 1'b0)begin
            sum <= 0;
            full_r <= 0;
        end else begin 
            if (wen_r) begin
                if (syn1_valid&syn2_valid) begin
                    for (i = 0; i<P; i=i+1) begin
                        sum[i*MWID+:MWID] <= syn1[i*MWID+:MWID] + syn2[i*MWID+:MWID]; // both ipt valid, write it!
                    end
                    full_r <= 1'b1;   // set flag to full
                end else begin
                    full_r <= 1'b0;
                end
            end
        end
    end

    assign syn = sum;
    assign syn1_ready = wen_r & syn2_valid; // syn2 valid, wait 1
    assign syn2_ready = wen_r & syn1_valid; // syn1 valid, wait 2
    assign syn_valid = full_r; // full indicate that we have data to send


endmodule