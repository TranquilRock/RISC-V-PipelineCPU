module Data_Memory
(
    clk_i,
    rst_i,
    addr_i,
    data_i,
    enable_i,
    write_i,
    ack_o,
    data_o
);

// Interface
input               clk_i;
input               rst_i;
input    [31:0]     addr_i;
input    [255:0]    data_i;
input               enable_i;
input               write_i;
output              ack_o;
output   [255:0]    data_o;


// Memory
reg      [255:0]    memory[0:511];    //16KB
reg      [3:0]      count;

reg      [255:0]    data;
wire     [26:0]     addr;

parameter STATE_IDLE            = 1'h0,
          STATE_WAIT            = 1'h1;            

reg        [1:0]        state;

assign    ack_o = (state == STATE_WAIT) && (count == 4'd9);
assign    addr = addr_i>>5;
assign    data_o = data;

always@(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
        state <= STATE_IDLE;
        count <= 4'd0;
    end
    else begin
        case(state) 
            STATE_IDLE: begin
                if(enable_i) begin
                    state <= STATE_WAIT;
                    count <= count + 1;
                end
            end
            STATE_WAIT: begin
                if(count == 4'd9) begin    
                    state <= STATE_IDLE;
                    count <= 0;
                end
                else begin
                    count <= count + 1;
                end
            end
        endcase    
    end
end


always@(posedge clk_i) begin
    if (ack_o) begin
        if (write_i) begin
            memory[addr] <= data_i;
            data <= data_i;
        end
        else begin
            data = memory[addr];
        end
    end
end

endmodule
