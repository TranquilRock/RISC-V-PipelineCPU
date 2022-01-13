`include "Define.v"
module Sign_Extend
(
    input [`DATA_LEN - 1: 0] data_i ,
    output reg[`DATA_LEN - 1: 0] data_o=`DATA_LEN   'b0
);
reg[`IMM_SIZE - 1:0] imm = `IMM_SIZE'b0;
always @(data_i)
begin
    case ( data_i[6:0])//OPcode
        {7'b0110011}: begin//R type: addi srai
            imm = `IMM_SIZE'b0;
        end 
        {7'b0010011}: begin//I type: addi srai
            imm = {data_i[`DATA_LEN - 1:`DATA_LEN - `IMM_SIZE]};
        end 
        {7'b0000011}: begin//lw
            imm = {data_i[`DATA_LEN - 1:`DATA_LEN - `IMM_SIZE]};
        end 
        {7'b0100011}: begin//sw
            imm = {data_i[`DATA_LEN - 1:`DATA_LEN - 1 - 6], data_i[11:7]};
        end 
        {7'b1100011}: begin//beq
            imm = {data_i[`DATA_LEN - 1],data_i[7],data_i[`DATA_LEN - 2:`DATA_LEN - 1 - 6], data_i[11:8]};//12, 10:5 + 4:1 , 11
        end 
        default: begin
            // $fdisplay(32'h8000_0002,"Sign_Extend: Instruction Not Found! '%b'",data_i);
        end
    endcase
    data_o =  { {(`DATA_LEN -`IMM_SIZE){imm[`IMM_SIZE - 1]}}, imm};
end
endmodule