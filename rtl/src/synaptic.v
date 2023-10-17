module synaptic #(
    parameter N = 128,
    parameter WID = 8
)(
    input clk, rst_n,

    input [3:0] enc,
    input [0:0] ipt_valid,

    output reg opt_valid,
    output reg [7:0] opt_syn
);
parameter ADDRWID = $clog2(N);
reg [7:0] mem[N-1:0];
reg [9:0] sum;

reg [ADDRWID-1:0] addr;

reg [3:0] cnt;

always @(posedge clk , negedge rst_n) begin
    if (rst_n == 1'b0) begin
        addr <= 0;
    end else begin
        if (ipt_valid) begin
            addr <= addr + enc[2:0] + enc[3];
        end
    end
end


always @(posedge clk , negedge rst_n) begin
    if (rst_n == 1'b0) begin
        cnt <= 0;
    end else begin
        cnt <= ipt_valid ? cnt + enc[3]: cnt;
    end
end

always @(posedge clk , negedge rst_n) begin
    if (rst_n == 1'b0) begin
        opt_valid = 0;
    end else begin
        opt_valid = cnt == 4'hf & enc[3];
    end
end

always @(posedge clk, rst_n) begin
    if (rst_n == 1'b0) begin
        opt_syn <= 0;
    end else begin
        opt_syn <= ipt_valid&enc[3]==0 ? opt_syn + mem[addr]:opt_syn;
    end
end

endmodule