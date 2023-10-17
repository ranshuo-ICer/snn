module lif #(
    parameter W_WID = 8,
    parameter W_NUM = 4,
    parameter TAU = 2,
    parameter VTH = 0,
    parameter VRES = 0
) (
    input clk,
    input rst_n,

    input signed [7:0] ir,
    output o_spike
);
    
reg signed [7:0] v_mem;

wire signed [7:0] delta_v = (ir - v_mem)>>>TAU;
wire signed [7:0] new_v = v_mem + delta_v;
assign o_spike = new_v > VTH;
wire [7:0] update_v = o_spike ? VRES:new_v;

always @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        v_mem <= VRES;
    end else begin
        v_mem <= update_v;
    end
end


endmodule