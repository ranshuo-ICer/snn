module idx_enc (
    input clk, rst_n,

    input ipt_valid,
    output reg [0:0] ipt_ready,
    input [7:0] sparse_bits,

    output reg [3:0] enc,
    output reg [0:0] opt_valid,
    input            opt_ready
);

localparam WAIT  = 'd0;
localparam ENC   = 'd1;
localparam ZERO = 'd2;       

reg [1:0] state;
reg [1:0] next_state;

reg [2:0] offset;
reg [7:0] data_tmp;
wire [7:0] data_shifted = data_tmp >> (offset);

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
                    if (sparse_bits == 8'd0)                next_state  <=  ZERO;
                    else                                    next_state  <=  ENC;
                else                                        next_state  <=  WAIT;
        ENC:    if (opt_ready)
                    if (data_shifted==8'b0000_0001)         next_state  <=  ZERO;
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
                        data_tmp    <=  {data_shifted[7:1], 1'b0};
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
    if (data_tmp[0]) offset = 3'b000;
    else if (data_tmp[1]) offset = 3'b001;
    else if (data_tmp[2]) offset = 3'b010;
    else if (data_tmp[3]) offset = 3'b011;
    else if (data_tmp[4]) offset = 3'b100;
    else if (data_tmp[5]) offset = 3'b101;
    else if (data_tmp[6]) offset = 3'b110;
    else if (data_tmp[7]) offset = 3'b111;
    else offset = 3'b000; // 默认输出
end

reg [2:0] cnt;
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
        enc <= {1'b1, 3'd7 - cnt};  //enc[3] = 1, end flag
        opt_valid <= 1'b1;
        ipt_ready <= 1'b0;
    end else begin
        enc <= 0;
        opt_valid <= 1'b0;
        ipt_ready <= 1'b0;
    end 
end

endmodule