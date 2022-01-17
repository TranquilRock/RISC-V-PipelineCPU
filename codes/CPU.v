`include "Define.v"
module CPU
(
    input clk_i, 
    input rst_i,
    input start_i,

    input  [256-1:0] mem_data_i, 
    input mem_ack_i,     
    output [256-1:0] mem_data_o, 
    output [32-1:0] mem_addr_o,     
    output mem_enable_o, 
    output mem_write_o
);

wire[`DATA_LEN - 1:0] IF_inst;
wire[`DATA_LEN - 1:0] IF_PC;
wire[`DATA_LEN - 1:0] IF_MUXResult;
wire[`DATA_LEN - 1:0] IF_AdderResult;

wire[`DATA_LEN - 1:0] ID_ExtendedImm;
wire[`DATA_LEN - 1:0] ID_AdderResult;
wire[`DATA_LEN - 1:0] ID_RS1;
wire[`DATA_LEN - 1:0] ID_inst;
wire[`DATA_LEN - 1:0] ID_PC;
wire[`DATA_LEN - 1:0] ID_RS2;
wire[1:0] ID_ALUOp;
wire ID_RegWrite;
wire ID_MemtoReg;
wire ID_MemRead;
wire ID_MemWrite;
wire ID_ALUSrc;

wire[`DATA_LEN - 1:0] EX_inst;
wire[`DATA_LEN - 1:0] EX_RS1;
wire[`DATA_LEN - 1:0] EX_RS2;
wire[`DATA_LEN - 1:0] EX_ExtendedImm;
wire[`DATA_LEN - 1:0] EX_ALUResult;
wire[`DATA_LEN - 1:0] EX_ALU2;
wire[`DATA_LEN - 1:0] EX_MUX2Result;
wire[`DATA_LEN - 1:0] EX_ALU1;
wire[2:0] EX_ALUCtr;
wire[1:0] EX_ALUOp;
wire EX_RegWrite;
wire EX_MemtoReg;
wire EX_MemRead;
wire EX_MemWrite;
wire EX_ALUSrc;

wire [`REG_SIZE - 1:0] MEM_rd;
wire [`DATA_LEN -1:0] MEM_ALUResult;
wire [`DATA_LEN -1:0] MEM_MuxResult;
wire [`DATA_LEN -1:0] MEM_DMData;
wire MEM_RegWrite;
wire MEM_MemRead;
wire MEM_MemWrite;
wire MEM_MemtoReg;

wire [`REG_SIZE -1:0] WB_Rd;
wire [`DATA_LEN -1:0] WB_WriteData;
wire [`DATA_LEN -1:0] WB_Rs1;
wire [`DATA_LEN -1:0] WB_Rs2;
wire WB_mux;
wire WB_RegWrite;

wire PCWrite;
wire Branch;
wire Stall;
wire NoOp;
wire [1:0] ForwardA;
wire [1:0] ForwardB;

wire MissStall;

reg Flush = 1'b0;
always @(ID_RS1 or ID_RS2 or Branch)
begin
    if((ID_RS1 == ID_RS2) && Branch)begin
        Flush = 1'b1;
    end
    else begin
        Flush = 1'b0;
    end
end

MUX2 IF_PCMUX(
    .data1_i    (IF_AdderResult),//PC ADD
    .data2_i    (ID_AdderResult),//Forward ADD
    .select_i   (Flush), //Forward AND
    .data_o     (IF_MUXResult) //PC IN
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .PCWrite_i  (PCWrite), //HAZARD PCWRITE
    .pc_i       (IF_MUXResult),
    .pc_o       (IF_PC),
    .stall_i(MissStall)
);

Adder IF_PCAdder(
    .data1_in   (IF_PC),
    .data2_in   ({32'b100}),
    .data_o     (IF_AdderResult)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (IF_PC), 
    .instr_o    (IF_inst)
);

PipeRegIFID IFID(
    .PC_i(IF_PC),
    .Stall_i(Stall),
    .inst_i(IF_inst),
    .Flush_i(Flush),
    .clk_i(clk_i),
    .inst_o(ID_inst),
    .rst_i(rst_i),
    .Data_Stall_i(MissStall),

    .PC_o(ID_PC)
);

Adder ID_PCAdder(
    .data1_in(ID_ExtendedImm << 1),// IMM extend<<1 JMP PC
    .data2_in(ID_PC),//PIPELINE PC
    .data_o(ID_AdderResult)
);

HazardDetectionUnit Hazard_Detection(
    .ID_rs1_i(ID_inst[19:15]),
    .ID_rs2_i(ID_inst[24:20]),
    .EX_rd_i(EX_inst[11: 7]),
    .MemRead_i(EX_MemRead),
    .PCWrite_o(PCWrite),
    .Stall_o(Stall),
    .NoOp_o(NoOp)
);

Control Control(
    .Op_i (ID_inst[6:0]),
    .NoOp_i(NoOp),
    .RegWrite_o (ID_RegWrite),
    .MemtoReg_o(ID_MemtoReg),
    .MemRead_o(ID_MemRead),
    .MemWrite_o(ID_MemWrite),
    .ALUOp_o (ID_ALUOp),
    .ALUSrc_o (ID_ALUSrc),
    .Branch_o(Branch)
);

Registers Registers(
    .clk_i      (clk_i),
    .RS1addr_i   (ID_inst[19:15]),
    .RS2addr_i   (ID_inst[24:20]),
    .RDaddr_i   (WB_Rd),
    .RDdata_i   (WB_WriteData),
    .RegWrite_i (WB_RegWrite), 
    .RS1data_o   (ID_RS1), 
    .RS2data_o   (ID_RS2) 
);

Sign_Extend ID_SignExtend(
    .data_i     (ID_inst),
    .data_o     (ID_ExtendedImm)
);

PipeRegIDEX IDEX(
    .RegWrite_i(ID_RegWrite),
    .MemtoReg_i(ID_MemtoReg),
    .MemWrite_i(ID_MemWrite),
    .MemRead_i(ID_MemRead),
    .ALUOp_i(ID_ALUOp),
    .ALUSrc_i(ID_ALUSrc),
    .inst_i(ID_inst),
    .Imm_i(ID_ExtendedImm),
    .Rd1_i(ID_RS1),
    .Rd2_i(ID_RS2),
    .clk_i(clk_i),
    .rst_i(rst_i),
    .Data_Stall_i(MissStall),

    .RegWrite_o(EX_RegWrite),
    .MemtoReg_o(EX_MemtoReg),
    .MemWrite_o(EX_MemWrite),
    .MemRead_o(EX_MemRead),
    .ALUOp_o(EX_ALUOp),
    .ALUSrc_o(EX_ALUSrc),
    .inst_o(EX_inst),
    .Rd1_o(EX_RS1),
    .Rd2_o(EX_RS2),
    .Imm_o(EX_ExtendedImm)
);

ALU_Control EX_ALUCtrUnit(
    .funct_i    ({EX_inst[31:25], EX_inst[14:12]}),
    .ALUOp_i    (EX_ALUOp),
    .ALUCtrl_o  (EX_ALUCtr)
);

MUX4 EX_MUX1(
    .data1_i    (EX_RS1),
    .data2_i    (WB_WriteData),
    .data3_i    (MEM_ALUResult),
    .data4_i    (),//X
    .select_i   (ForwardA),//ForwardA
    .data_o     (EX_ALU1)//ALU0
);

MUX4 EX_MUX2(
    .data1_i    (EX_RS2),
    .data2_i    (WB_WriteData),
    .data3_i    (MEM_ALUResult),
    .data4_i    (),//X
    .select_i   (ForwardB),//ForwardB
    .data_o     ( EX_MUX2Result)//MUX_ALU1
); 

MUX2 EX_MUXALUSrc(
    .data1_i    (EX_MUX2Result),
    .data2_i    (EX_ExtendedImm),
    .select_i   (EX_ALUSrc),
    .data_o     (EX_ALU2)
);

ALU EX_ALU(
    .data1_i    (EX_ALU1),
    .data2_i    (EX_ALU2),
    .ALUCtrl_i  (EX_ALUCtr),
    .data_o     (EX_ALUResult),
    .Zero_o     ()//X
);

ForwardingUnit forwardUnit(
    .EX_Rs1_i(EX_inst[19:15]),
    .EX_Rs2_i(EX_inst[24:20]),

    .MEM_RegWrite_i(MEM_RegWrite),
    .MEM_Rd_i(MEM_rd),

    .WB_RegWrite_i(WB_RegWrite),
    .WB_Rd_i(WB_Rd),
    
    .ForwardA_o(ForwardA),
    .ForwardB_o(ForwardB)
);

PipeRegEXMEM EXMEM(
    .RegWrite_i(EX_RegWrite),
    .MemtoReg_i(EX_MemtoReg),
    .MemWrite_i(EX_MemWrite),
    .MemRead_i(EX_MemRead),
    .rd_i(EX_inst[11:7]),
    .MuxResult_i(EX_MUX2Result),
    .ALUResult_i(EX_ALUResult),
    .clk_i(clk_i),
    .rst_i(rst_i),
    .Data_Stall_i(MissStall),

    .RegWrite_o(MEM_RegWrite),
    .MemtoReg_o(MEM_MemtoReg),
    .MemWrite_o(MEM_MemWrite),
    .MemRead_o(MEM_MemRead),
    .rd_o(MEM_rd),
    .MuxResult_o(MEM_MuxResult),
    .ALUResult_o(MEM_ALUResult)
);

dcache_controller dcache(
    .clk_i(clk_i),
    .rst_i(rst_i),
    // to Data Memory interface
    .mem_data_i(mem_data_i), 
    .mem_ack_i(mem_ack_i),

    .mem_data_o(mem_data_o), 
    .mem_addr_o(mem_addr_o),     
    .mem_enable_o(mem_enable_o), 
    .mem_write_o(mem_write_o), 
    // to CPU interface    
    .cpu_data_i(MEM_MuxResult),
    .cpu_addr_i(MEM_ALUResult), 
    .cpu_MemRead_i(MEM_MemRead),
    .cpu_MemWrite_i(MEM_MemWrite),

    .cpu_data_o(MEM_DMData),
    .cpu_stall_o(MissStall)
);

PipeRegMEMWB MEMWB(
    .RegWrite_i(MEM_RegWrite),
    .MemtoReg_i(MEM_MemtoReg),
    .rd_i(MEM_rd),
    .Rs1_i(MEM_ALUResult),
    .Rs2_i(MEM_DMData),
    .clk_i(clk_i),
    .rst_i(rst_i),
    .Data_Stall_i(MissStall),

   .RegWrite_o(WB_RegWrite),
   .MemtoReg_o(WB_mux),
   .rd_o(WB_Rd),
   .Rs1_o(WB_Rs1),
   .Rs2_o(WB_Rs2)
);

MUX2 WB_MUX(
    .data1_i(WB_Rs1),
    .data2_i(WB_Rs2),
    .select_i(WB_mux),
    .data_o(WB_WriteData)
);
endmodule

// always @*
//     $display("%b",{IF_inst[31:25], IF_inst[14:12]});
