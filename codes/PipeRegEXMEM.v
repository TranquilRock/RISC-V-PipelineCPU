`include "Define.v"
module PipeRegEXMEM
(
    input RegWrite_i ,
    input MemtoReg_i ,
    input MemWrite_i ,
    input MemRead_i ,
    input [`REG_SIZE - 1: 0] rd_i ,
    input [`DATA_LEN - 1: 0] MuxResult_i ,
    input [`DATA_LEN - 1: 0] ALUResult_i ,
    input clk_i,
    input rst_i,
    input Data_Stall_i, //TODO

    output RegWrite_o ,
    output MemtoReg_o ,
    output MemWrite_o ,
    output MemRead_o ,
    output[`REG_SIZE - 1: 0] rd_o,
    output[`DATA_LEN - 1: 0] MuxResult_o,
    output[`DATA_LEN - 1: 0] ALUResult_o
);

reg [`DATA_LEN - 1:0] register [0:6];

assign  RegWrite_o = register[0][0];
assign  MemtoReg_o = register[1][0];
assign  MemWrite_o = register[2][0];
assign  MemRead_o = register[3][0];
assign  rd_o = register[4][`REG_SIZE - 1: 0];
assign  MuxResult_o = register[5];
assign  ALUResult_o = register[6];



always@(posedge clk_i) begin
    register[0][0] <= RegWrite_i;
    register[1][0] <= MemtoReg_i;
    register[2][0] <= MemWrite_i;
    register[3][0] <=MemRead_i;
    register[4][`REG_SIZE - 1: 0] <= rd_i;
    register[5] <= MuxResult_i;
    register[6] <= ALUResult_i;

    // $fdisplay(32'h8000_0002,"EX_MEM DATA'%b' REG'%b'", MuxResult_i, rd_i);

end
endmodule