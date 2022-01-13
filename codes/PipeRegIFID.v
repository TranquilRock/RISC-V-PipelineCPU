`include "Define.v"
module PipeRegIFID
(
    input [`DATA_LEN - 1: 0] PC_i ,
    input [`DATA_LEN - 1: 0] inst_i ,
    input Stall_i ,
    input Flush_i ,
    input clk_i,
    input rst_i,
    input Data_Stall_i,//TODO

    output [`DATA_LEN - 1: 0] inst_o,
    output [`DATA_LEN - 1: 0] PC_o
);
reg [`DATA_LEN - 1:0]register [0:1];
assign  PC_o = register[0];
assign  inst_o = register[1];

always@(posedge clk_i) begin
    if(Flush_i) begin
        //PC_o Don't care
        register[1] <= `DATA_LEN'b0000000_00000_00000_000_00000_0110011;//add r0, r0, r0 not sure
    end
    else if (!Stall_i) begin
        register[0] <= PC_i;
        register[1] <= inst_i;
    end
end
endmodule