`include "Define.v"
module Control
(
    input [`OP_LEN - 1: 0] Op_i ,
    input NoOp_i,

    output reg RegWrite_o=1'b0,
    output reg MemtoReg_o=1'b0,
    output reg MemRead_o=1'b0,
    output reg MemWrite_o=1'b0,
    output reg[`ALUOP_LEN - 1: 0] ALUOp_o=`ALUOP_LEN'b0,
    output reg ALUSrc_o=1'b0,
    output reg Branch_o=1'b0
);
always @(Op_i or NoOp_i)
begin
    if(NoOp_i)begin
        RegWrite_o = 1'b0;
        MemtoReg_o = 1'b0;
        MemRead_o = 1'b0;
        MemWrite_o = 1'b0;
        ALUOp_o = `ALUOP_NO;//Not sure if 2'b11 is actually used in Risc-v.
        ALUSrc_o = 1'b0;
        Branch_o = 1'b0;
    end
    else begin
        case (Op_i)
            {7'b0110011}:begin//R type: and xor sll add sub mul
                RegWrite_o = 1'b1;//Always write
                MemtoReg_o = 1'b0;
                MemRead_o = 1'b0;
                MemWrite_o = 1'b0;
                ALUOp_o = `ALUOP_R;
                ALUSrc_o = 1'b0;
                Branch_o = 1'b0;
            end 
            {7'b0010011}: begin//I type: addi srai
                RegWrite_o = 1'b1;//Always write
                MemtoReg_o = 1'b0;
                MemRead_o = 1'b0;
                MemWrite_o = 1'b0;
                ALUOp_o = `ALUOP_I;
                ALUSrc_o = 1'b1;
                Branch_o = 1'b0;
            end 
            {7'b0000011}: begin//lw
                RegWrite_o = 1'b1;
                MemtoReg_o = 1'b1;
                MemRead_o = 1'b1;
                MemWrite_o = 1'b0;
                ALUOp_o = `ALUOP_LSW;
                ALUSrc_o = 1'b1;//IMM
                Branch_o = 1'b0;
            end 
            {7'b0100011}: begin//sw
                RegWrite_o = 1'b0;
                MemtoReg_o = 1'b0;
                MemRead_o = 1'b0;
                MemWrite_o = 1'b1;
                ALUOp_o = `ALUOP_LSW;
                ALUSrc_o =1'b1;//IMM
                Branch_o = 1'b0;
            end 
            {7'b1100011}: begin//beq
                RegWrite_o = 1'b0;
                MemtoReg_o = 1'b0;
                MemRead_o = 1'b0;
                MemWrite_o = 1'b0;
                ALUOp_o = `ALUOP_I;
                ALUSrc_o = 1'b1; //ADDR
                Branch_o = 1'b1;
            end 
            default: begin
                RegWrite_o = 1'b0;
                MemtoReg_o = 1'b0;
                MemRead_o = 1'b0;
                MemWrite_o = 1'b0;
                ALUOp_o = `ALUOP_R;
                ALUSrc_o = 1'b0;
                Branch_o = 1'b0;
                //Avoid case all 0 instruction
                // $fdisplay(32'h8000_0002,"Control: Instruction Not Found! '%b'", Op_i);
            end
        endcase
    end
end
endmodule