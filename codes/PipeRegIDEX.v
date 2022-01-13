`include "Define.v"
module PipeRegIDEX
(
    input RegWrite_i ,
    input MemtoReg_i ,
    input MemWrite_i ,
    input MemRead_i ,
    input [`ALUOP_LEN - 1 : 0]ALUOp_i,
    input ALUSrc_i ,
    input [`DATA_LEN - 1: 0] inst_i ,
    input [`DATA_LEN - 1: 0] Imm_i ,
    input [`DATA_LEN - 1: 0] Rd1_i ,
    input [`DATA_LEN - 1: 0] Rd2_i ,
    input clk_i,
    input rst_i,
    input Data_Stall_i,//TODO


    output RegWrite_o ,
    output MemtoReg_o ,
    output MemWrite_o ,
    output MemRead_o ,
    output [`ALUOP_LEN - 1 : 0]ALUOp_o,
    output ALUSrc_o ,
    output [`DATA_LEN - 1: 0] inst_o,
    output [`DATA_LEN - 1: 0] Rd1_o,
    output [`DATA_LEN - 1: 0] Rd2_o,
    output [`DATA_LEN - 1: 0] Imm_o
);
reg [`DATA_LEN - 1:0] register [0:9];

assign  RegWrite_o = register[0][0];
assign  MemtoReg_o = register[1][0];
assign  MemWrite_o = register[2][0];
assign  MemRead_o = register[3][0];
assign  ALUOp_o = register[4][1:0];
assign  ALUSrc_o = register[5][0];
assign  inst_o = register[6];
assign  Imm_o = register[7];
assign  Rd1_o = register[8];
assign  Rd2_o = register[9];

always@(posedge clk_i) begin
    register[0][0] <= RegWrite_i;
    register[1][0] <= MemtoReg_i;
    register[2][0] <= MemWrite_i;
    register[3][0] <=MemRead_i;
    register[4][`ALUOP_LEN - 1 : 0] <= ALUOp_i;
    register[5][0] <= ALUSrc_i;
    register[6][`DATA_LEN - 1: 0] <= inst_i;
    register[7][`DATA_LEN - 1: 0] <= Imm_i;
    register[8][`DATA_LEN - 1: 0] <= Rd1_i;
    register[9][`DATA_LEN - 1: 0] <= Rd2_i;
end
endmodule