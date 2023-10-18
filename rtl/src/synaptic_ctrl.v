module synaptic_ctrl #(
    parameter N = 128,
    parameter WID = 8,
    parameter MWID = 12,
    parameter ADDRWID = $clog2(N)
)(
    input clk, rst_n,

    input [5:0] enc,
    input [0:0] ipt_valid,
    output      ipt_ready,
    
    output syn_mem_ren,
    output [ADDRWID-1:0] syn_mem_raddr,
    // input [WID-1:0] syn_mem_out,

    output acc_clr,
    output acc_valid,

    output opt_valid,
    input opt_ready
    // output reg [MWID-1:0] opt_syn
);

    localparam ENC_WID = 6;

    wire opt_hsk = opt_ready&opt_valid;
    wire ipt_hsk = ipt_ready&ipt_valid;

    assign ipt_ready = opt_valid ? opt_ready:1'b1;

    // reg [7:0] mem[N-1:0];
    reg [ADDRWID-1:0] mem_addr;
    assign syn_mem_raddr = mem_addr;
    wire mem_ren;
    assign syn_mem_ren = mem_ren;
    // wire [WID-1:0] mem_out;
    // assign mem_out = syn_mem_out;
    
    // always @(posedge clk , negedge rst_n) begin
    //     if (rst_n==1'b0) begin
    //         mem_out <= 0;
    //     end else begin
    //         if (mem_ren) begin
    //             mem_out <= mem[mem_addr];
    //         end
    //     end
    // end
    
    // integer i;
    // initial begin
    //     for (i = 0; i<N; i=i+1) begin
    //         mem[i] = i;
    //     end
    // end
    
    localparam IT_NUM = N/32;  //总共N个权重，每次处理ENC_WID个
    localparam CNT_WID = $clog2(IT_NUM);
    reg [CNT_WID-1:0] cnt;
    
    reg [1:0] ipt_valid_delay;
    reg [1:0] end_flag_delay;
    always @(posedge clk , negedge rst_n) begin
        if (rst_n == 1'b0) begin
            ipt_valid_delay <= 0;
            end_flag_delay <= 0;
        end else if(ipt_ready) begin
            ipt_valid_delay[0] <= ipt_valid;
            ipt_valid_delay[1] <= ipt_valid_delay[0];
            
            end_flag_delay[0] <= enc[ENC_WID-1];
            end_flag_delay[1] <= end_flag_delay[0];
        end
    end
    
    assign mem_ren = ipt_valid_delay[0]&end_flag_delay[0]==0;

    always @(posedge clk , negedge rst_n) begin
        if (rst_n == 1'b0) begin
            mem_addr <= 0;
        end else if(ipt_ready) begin
            mem_addr <= ipt_valid ? mem_addr + enc[ENC_WID-2:0] + enc[ENC_WID-1]: mem_addr;
        end
    end
    
    
    always @(posedge clk , negedge rst_n) begin
        if (rst_n == 1'b0) begin
            cnt <= 0;
        end else if(ipt_ready) begin
            cnt <= ipt_valid ? cnt + enc[ENC_WID-1]: cnt;
        end
    end


    reg [1:0] opt_valid_delay;
    assign opt_valid = opt_valid_delay[1];
    always @(posedge clk , negedge rst_n) begin
        if (rst_n == 1'b0) begin
            opt_valid_delay = 0;
        end else if(ipt_ready) begin
            opt_valid_delay[0] <= cnt == {CNT_WID{1'b1}} & enc[ENC_WID-1];
            opt_valid_delay[1] <= opt_valid_delay[0];
        end
    end
    
    // always @(posedge clk, negedge rst_n) begin
    //     if (rst_n == 1'b0) begin
    //         opt_syn <= 0;
    //     end else begin
    //         if(opt_hsk)begin
    //             opt_syn <= 0;
    //         end else begin
    //             opt_syn <= ipt_valid_delay[1]&end_flag_delay[1]==0 ? opt_syn + mem_out:opt_syn;
    //         end
    //     end
    // end

    assign acc_clr = opt_hsk;
    assign acc_valid = ipt_valid_delay[1]&end_flag_delay[1]==0;

endmodule