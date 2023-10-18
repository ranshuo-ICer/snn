module weight_ram #(
    parameter DEEPTH = 512,
    parameter ADDRWID = $clog2(DEEPTH),
    parameter P = 64,
    parameter WIDTH = 8*P
) (
    input clk,
    input rst_n,

    input [ADDRWID-1:0] raddr,
    output reg [WIDTH-1:0] rdata,
    input ren
);

    reg [WIDTH-1:0] mem[DEEPTH-1:0];

    integer i;
    reg [7:0] tmp;
    initial begin
        
        for (i = 0; i<DEEPTH; i=i+1) begin
            tmp = i;
            mem[i] = {P{tmp}};
        end
    end

    always @(posedge clk , negedge rst_n) begin
        if (rst_n==1'b0) begin
            rdata <= 0;
        end else begin
            if (ren) begin
                rdata <= mem[raddr];
            end
        end
    end

endmodule