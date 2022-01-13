`ifndef AND
`define AND 3'b000
`endif

`ifndef OR
`define OR  3'b001
`endif

`ifndef XOR
`define XOR 3'b010
`endif

`ifndef ADD
`define ADD 3'b011
`endif

`ifndef SUB
`define SUB 3'b100
`endif

`ifndef MUL
`define MUL 3'b101
`endif

`ifndef SLL
`define SLL 3'b110
`endif

`ifndef SRAI
`define SRAI 3'b111
`endif
//=======================================
`ifndef FUNC_LEN
`define FUNC_LEN 10
`endif

`ifndef DATA_LEN
`define DATA_LEN 32
`endif

`ifndef CRTL_LEN
`define CRTL_LEN 3
`endif

`ifndef OP_LEN
`define OP_LEN 7
`endif

`ifndef ALUOP_LEN
`define ALUOP_LEN 2
`endif

`ifndef ALUSRC_LEN
`define ALUSRC_LEN 1
`endif

`ifndef REGWRITE_LEN
`define REGWRITE_LEN 1
`endif
//=======================================

`ifndef IMM_SIZE
`define IMM_SIZE 12
`endif

`ifndef REG_SIZE
`define REG_SIZE 5
`endif
//=======================================

`ifndef ALUOP_R
`define  ALUOP_R 2'b10
`endif
`ifndef ALUOP_LSW
`define  ALUOP_LSW 2'b00
`endif

`ifndef ALUOP_I
`define  ALUOP_I 2'b01
`endif

`ifndef ALUOP_NO
`define  ALUOP_NO 2'b11
`endif