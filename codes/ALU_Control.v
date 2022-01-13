`include "Define.v"
module ALU_Control
(
    input [`FUNC_LEN - 1: 0] funct_i,
    input [`ALUOP_LEN - 1: 0] ALUOp_i,
    output reg[`CRTL_LEN - 1: 0] ALUCtrl_o = `CRTL_LEN'b0
);

always @(funct_i or ALUOp_i)
begin
    if(ALUOp_i == `ALUOP_I) begin
        if (funct_i[2:0] == 3'b0)begin
            ALUCtrl_o = `ADD;//ADDI
        end
        else if (funct_i == {7'b0100000, 3'b101}) begin
            ALUCtrl_o = `SRAI;
        end
        //Doesn't handle beq here, since ALU can't connect to PC.
    end
    else if(ALUOp_i == `ALUOP_R) begin
        case (funct_i)
            {7'b0, 3'b111}: ALUCtrl_o = `AND;
            {7'b0, 3'b100}: ALUCtrl_o = `XOR;
            {7'b0, 3'b001}: ALUCtrl_o = `SLL;
            {7'b0, 3'b0}:  ALUCtrl_o = `ADD;
            {7'b0100000, 3'b0}: ALUCtrl_o = `SUB;
            {7'b1, 3'b0}: ALUCtrl_o = `MUL;
            default:begin
                // $fdisplay(32'h8000_0002,"Error in ALU_Control R-type %b",funct_i);
            end
        endcase
    end
    else if(ALUOp_i == `ALUOP_LSW) begin
        ALUCtrl_o = `ADD; // Like addi
    end
    else begin
        // $fdisplay(32'h8000_0002,"ALU Control: ALUOP Not Found!");
    end
end
endmodule