`include "Define.v"
module MUX4
(
    input [`DATA_LEN - 1: 0] data1_i ,
    input [`DATA_LEN - 1: 0] data2_i ,
    input [`DATA_LEN - 1: 0] data3_i ,
    input [`DATA_LEN - 1: 0] data4_i ,
    input [1: 0]select_i,
    output reg[`DATA_LEN - 1: 0] data_o=`DATA_LEN'b0
);

always @(select_i or data1_i or data2_i or data3_i or data4_i)
begin
    case (select_i)
        {2'b00}:begin
            data_o = data1_i;
        end
        {2'b01}:begin
            data_o = data2_i;
        end
        {2'b10}:begin
            data_o = data3_i;
        end
        {2'b11}:begin
            data_o = data4_i;
        end
    endcase
end
endmodule