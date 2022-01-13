`include "Define.v"
module ForwardingUnit
(
    input [`REG_SIZE - 1: 0] EX_Rs1_i ,
    input [`REG_SIZE - 1: 0] EX_Rs2_i ,

    input MEM_RegWrite_i ,
    input [`REG_SIZE - 1: 0] MEM_Rd_i ,

    input WB_RegWrite_i ,
    input [`REG_SIZE - 1: 0] WB_Rd_i ,

    output reg[1: 0] ForwardA_o=2'b0,
    output reg[1: 0] ForwardB_o=2'b0
);

always @(EX_Rs1_i or EX_Rs2_i or MEM_RegWrite_i or MEM_Rd_i or WB_RegWrite_i or WB_Rd_i)
begin
    if (MEM_RegWrite_i && (MEM_Rd_i != 0) && (MEM_Rd_i == EX_Rs1_i)) begin 
        ForwardA_o = 2'b10;
    end
    else if (WB_RegWrite_i 
        && (WB_Rd_i != 0) 
        && !(MEM_RegWrite_i && (MEM_Rd_i != 0) && (MEM_Rd_i == EX_Rs1_i)) 
        && (WB_Rd_i == EX_Rs1_i)) begin 
            ForwardA_o = 2'b01;
    end
    else begin
        ForwardA_o = 2'b0;
    end
    if (MEM_RegWrite_i && (MEM_Rd_i != 0) && (MEM_Rd_i == EX_Rs2_i)) begin
        ForwardB_o = 2'b10;
    end 
    else if (WB_RegWrite_i
        && (WB_Rd_i != 0)
        && !(MEM_RegWrite_i && (MEM_Rd_i != 0) && (MEM_Rd_i == EX_Rs2_i))
        && (WB_Rd_i == EX_Rs2_i)) begin 
            ForwardB_o = 2'b01;
    end
    else begin
        ForwardB_o = 2'b0;
    end
end
endmodule