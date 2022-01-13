`include "Define.v"
module ALU
(
    input [`DATA_LEN - 1: 0] data1_i,
    input [`DATA_LEN - 1: 0] data2_i,
    input [`CRTL_LEN - 1: 0] ALUCtrl_i,
    output reg[`DATA_LEN - 1: 0] data_o = `DATA_LEN'b0,
    output reg Zero_o = 1'b0
);

always @(data1_i or data2_i or ALUCtrl_i) // I think this should be removed?
begin
    case(ALUCtrl_i)
        `AND:  data_o = data1_i & data2_i;
        `XOR:  data_o = data1_i ^ data2_i;
        `SLL: data_o = data1_i << data2_i;
        `ADD:  data_o = data1_i + data2_i;
        `SUB:  data_o = data1_i - data2_i;
        `MUL:  data_o = data1_i * data2_i;
        `SRAI: data_o = data1_i >>> data2_i[4:0];//The effective imm is actually 5 bits
        `OR:   data_o = data1_i | data2_i;//Not needed
    endcase
    Zero_o = (data_o == 0) ? 1 : 0;
end
endmodule