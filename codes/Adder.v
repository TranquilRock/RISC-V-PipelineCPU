`include "Define.v"
module Adder
(
    input [`DATA_LEN - 1: 0] data1_in ,
    input [`DATA_LEN - 1: 0] data2_in ,
    output reg[`DATA_LEN - 1: 0] data_o=`DATA_LEN'b0
);

always @(data1_in or data2_in)
begin
    data_o = data1_in + data2_in;
end
endmodule