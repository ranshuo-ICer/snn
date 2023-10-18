module idx_enc_32 (
    input clk, rst_n,

    input ipt_valid,
    output reg [0:0] ipt_ready,
    input [31:0] sparse_bits,

    output reg [5:0] enc,
    output reg [0:0] opt_valid,
    input            opt_ready
);

localparam WAIT  = 'd0;
localparam ENC   = 'd1;
localparam ZERO = 'd2;       

reg [1:0] state;
reg [1:0] next_state;

reg [4:0] offset;
reg [31:0] data_tmp;
wire [31:0] data_shifted = data_tmp >> (offset);

always @(posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0) begin
        state <= WAIT;
    end else begin
        state <= next_state;
    end
end


always@(*)begin
    case (state)
        WAIT:   if (ipt_valid)
                    if (sparse_bits == 32'd0)                next_state  <=  ZERO;
                    else                                    next_state  <=  ENC;
                else                                        next_state  <=  WAIT;
        ENC:    if (opt_ready)
                    if (data_shifted==32'b0000_0000_0000_0000_0000_0000_0000_0001)         next_state  <=  ZERO;
                    else                                    next_state  <=  ENC;
                else                                        next_state  <=  ENC;
        ZERO:   if (opt_ready)                              next_state  <=  WAIT;
                else                                        next_state  <=  ZERO;
        default:                                            next_state  <=  WAIT;
    endcase
end


always @(posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0) begin
        data_tmp <= 0;
    end else begin
        case (state)
            WAIT:   if(ipt_valid)    
                        data_tmp    <=  sparse_bits;
                    else
                        data_tmp    <=  0;
            ENC:    if(opt_ready)
                        data_tmp    <=  {data_shifted[31:1], 1'b0};
                    else
                        data_tmp    <=  data_tmp;
            ZERO:       data_tmp    <=  0;
            default:    data_tmp    <=  0;
        endcase
    end
end

//优先编码器，case这种写法不对吗？
// always @(*) begin
//     case (data_tmp)
//         8'bxxxx_xxx1: offset <= 3'd0;
//         8'bxxxx_xx10: offset <= 3'd1;
//         8'bxxxx_x100: offset <= 3'd2;
//         8'bxxxx_1000: offset <= 3'd3;
//         8'bxxx1_0000: offset <= 3'd4;
//         8'bxx10_0000: offset <= 3'd5;
//         8'bx100_0000: offset <= 3'd6;
//         8'b1000_0000: offset <= 3'd7;
//         default: offset <= 3'd0;
//     endcase
// end

always @* begin
    if      (data_tmp[0]) offset <= 5'd0;
    else if (data_tmp[1]) offset <= 5'd1;
    else if (data_tmp[2]) offset <= 5'd2;
    else if (data_tmp[3]) offset <= 5'd3;
    else if (data_tmp[4]) offset <= 5'd4;
    else if (data_tmp[5]) offset <= 5'd5;
    else if (data_tmp[6]) offset <= 5'd6;
    else if (data_tmp[7]) offset <= 5'd7;
    else if (data_tmp[8]) offset <= 5'd8;
    else if (data_tmp[9]) offset <= 5'd9;
    else if (data_tmp[10]) offset <= 5'd10;
    else if (data_tmp[11]) offset <= 5'd11;
    else if (data_tmp[12]) offset <= 5'd12;
    else if (data_tmp[13]) offset <= 5'd13;
    else if (data_tmp[14]) offset <= 5'd14;
    else if (data_tmp[15]) offset <= 5'd15;
    else if (data_tmp[16]) offset <= 5'd16;
    else if (data_tmp[17]) offset <= 5'd17;
    else if (data_tmp[18]) offset <= 5'd18;
    else if (data_tmp[19]) offset <= 5'd19;
    else if (data_tmp[20]) offset <= 5'd20;
    else if (data_tmp[21]) offset <= 5'd21;
    else if (data_tmp[22]) offset <= 5'd22;
    else if (data_tmp[23]) offset <= 5'd23;
    else if (data_tmp[24]) offset <= 5'd24;
    else if (data_tmp[25]) offset <= 5'd25;
    else if (data_tmp[26]) offset <= 5'd26;
    else if (data_tmp[27]) offset <= 5'd27;
    else if (data_tmp[28]) offset <= 5'd28;
    else if (data_tmp[29]) offset <= 5'd29;
    else if (data_tmp[30]) offset <= 5'd30;
    else if (data_tmp[31]) offset <= 5'd31;
    else offset = 5'd0; // 默认输出
end

reg [4:0] cnt;
always @(posedge clk , negedge rst_n) begin
    if (rst_n == 1'b0) begin
        cnt <= 0;
    end else begin
        case (state)
            WAIT:                   cnt <= 0;
            ENC:    if(opt_ready)   cnt <= cnt + offset;
                    else            cnt <= cnt;
            ZERO:                   cnt <= cnt;
            default:                cnt <= 0;
        endcase
    end
end

always@(*)begin
    if (state == WAIT) begin
        enc <= 0;
        opt_valid <= 1'b0;
        ipt_ready <= 1'b1;
    end else if (state == ENC) begin
        enc <= {1'b0, offset};
        opt_valid <= 1'b1;
        ipt_ready <= 1'b0;
    end else if (state == ZERO) begin
        enc <= {1'b1, 5'd31 - cnt};  //enc[3] = 1, end flag
        opt_valid <= 1'b1;
        ipt_ready <= 1'b0;
    end else begin
        enc <= 0;
        opt_valid <= 1'b0;
        ipt_ready <= 1'b0;
    end 
end

endmodule