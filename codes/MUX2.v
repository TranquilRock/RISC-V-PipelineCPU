`include "Define.v"
module MUX2
(
    input [`DATA_LEN - 1: 0] data1_i ,
    input [`DATA_LEN - 1: 0] data2_i ,
    input select_i,
    output reg[`DATA_LEN - 1: 0] data_o=`DATA_LEN'b0
);

always @(select_i or data1_i or data2_i)
begin
    data_o = select_i == 0 ? data1_i : data2_i;
end
endmodule