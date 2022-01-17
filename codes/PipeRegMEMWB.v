`include "Define.v"
module PipeRegMEMWB
(
    input RegWrite_i ,
    input MemtoReg_i ,
    input [`REG_SIZE - 1: 0] rd_i ,
    input [`DATA_LEN - 1: 0] Rs1_i ,
    input [`DATA_LEN - 1: 0] Rs2_i ,
    input clk_i,
    input rst_i,
    input Data_Stall_i, //TODO

    output RegWrite_o ,
    output MemtoReg_o ,
    output[`REG_SIZE - 1: 0] rd_o,
    output[`DATA_LEN - 1: 0] Rs1_o,
    output[`DATA_LEN - 1: 0] Rs2_o
);
reg [`DATA_LEN - 1:0] register [0:4];

assign  RegWrite_o = register[0][0];
assign  MemtoReg_o = register[1][0];
assign  rd_o = register[2][`REG_SIZE - 1: 0];
assign  Rs1_o = register[3];
assign  Rs2_o = register[4];
always@(posedge clk_i) begin
    if (!Data_Stall_i) begin
        register[0][0] <= RegWrite_i;
        register[1][0] <= MemtoReg_i;
        register[2][`REG_SIZE - 1: 0] <= rd_i;
        register[3] <= Rs1_i;
        register[4] <= Rs2_i;
    end
end
endmodule