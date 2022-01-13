`include "Define.v"
module HazardDetectionUnit
(
    input [`REG_SIZE -1: 0] ID_rs1_i ,
    input [`REG_SIZE -1: 0] ID_rs2_i ,
    input [`REG_SIZE -1: 0] EX_rd_i ,
    input MemRead_i,
    
    output reg PCWrite_o=1'b0,
    output reg NoOp_o=1'b0,
    output reg Stall_o=1'b0
);

always @(ID_rs1_i or ID_rs2_i or EX_rd_i or MemRead_i)
begin//Remember x0 case!
    if(MemRead_i && (EX_rd_i != 0) && (ID_rs1_i == EX_rd_i || ID_rs2_i == EX_rd_i)) begin
        PCWrite_o=1'b0;//Stall happened, freeze PC.
        NoOp_o=1'b1;
        Stall_o=1'b1;
    end
    else begin
        PCWrite_o=1'b1;
        NoOp_o=1'b0;
        Stall_o=1'b0;
    end
end
endmodule