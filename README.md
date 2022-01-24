# RISC-V-PipelineCPU
NTU Computer Architecture 2021 - CPU with Single issue, L1-cache
## codes
1. CPU.v
	- This module follows  datapath as the figure provided in spec, connect all submodules to function as a pipelined cpu with data cache. The only difference between this version and CPU.v in lab1 is that it connects to Data Cache instead of Data Memory.

1. ALU.v
	- This module takes three inputs, two of them are data with 32 bits(data1_i, data2_i), the other is control signal with 3 bits(ALUCtrl_i).
	- Action is taken whenever one of the data or signal changes, and the action is determined by control signal.
	- There are 8 action types: addition, or operation, xor operation, and operation, subtraction, multiplication, shift left operation(logical), shift right operation(arithmetic).
	- The result of action will be store into one of the two output(data_o), and the other output(Zero_o) will be set if data_o is zero.

1. ALU_control.v
	- This module takes two inputs, used to indicate function(funct_i) and ALU operation(ALUOp_i), and they are 10 and 7 bits respectively.
	- Whenever the funct_i or the ALUOp_i is changed, this module will set its output(ALUCtrl_o) accordingly.
	- There are 8 different outputs corresponding to the adforementioned ALU actions.

1. Adder.v
	- This module takes two 32bits inputs(data1_in, data2_in) and simply outputs the addition of two input(discard overflow bit) as data_o everytime the inputs change.

1. Control.v
	- Control.v takes 2 inputs(Op_i, NoOp_i), and set its 7 outputs(RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o, ALUOp_o, ALUSrc_o, Branch_o) accordingly.
	- The outputs are decided in response to the change of Op_i or NoOp_i, and 6 categories of cases are considered(NoOp, R-type, I-type,lw ,sw ,beq).

1. ForwadingUnit.v
	- To minimize bubble in pipeline, this module is used to check if a forwarding is needed for the instruction to operate correctly.
	- It takes 6 inputs from 3 different stages(EX_Rs1_i, EX_Rs2_i, MEM_RegWrite_i, MEM_Rd_i, WB_RegWrite_i, WB_Rd_i), and 2 outputs (ForwardA_o, ForwardB_o)to select the resource of EX stage's ALU.

1. HazardDetectionUnit.v
	- This module takes 4 inputs(ID_rs1_i, ID_rs2_i, EX_rd_i, MemRead_i) to check whether the current instruction will lead to wrong execution, if so, stall the pipeline by changing its output PCWrite_o, NoOp_o, Stall_o.

1. MUX2.v
	- This module takes two 32bits inputs(data1_i, data2_i) and an one bit input(select_i).
	- As soon as any of its input changes, 32bits output(data_o) is set to be the value of datak_i where k = select_i's value + 1.

1. MUX4.v
	- This module takes four 32bits inputs(data1_i, data2_i, data3_i, data4_i) and an 2 bit input(select_i).
	- As soon as any of its input changes, 32bits output(data_o) is set to be  the value of datak_i, where k is the value of select_i + 1.

1. PipeRegIFID
	- Register between IF and ID stage.
	- The module takes 5 inputs(PC_i, inst_i, Stall_i, Flush_i, clk_i) and pass the (inst_i, PC_i) to ID stage for further execution.
	- The module only changes upon posedge of clk_i.
		- It checks if Flush_i or Stall_i is set, and action as below.
			- If Flush_i is set, inst_i is set to the instruction "add x0, x0, x0" (which works similar to no-op)
			- Otherwise if neither Flush_i nor Stall_i, the module forward PC_o and inst_o to ID stage.

1. PipeRegIDEX
	- Register between ID and EX stage.
	- The module takes 11 inputs, simply forwarding all of them to outputs (except clk_i), and only changes upon posedge of clk_i.
	- The inputs and outputs are listed below:
		- Inputs: RegWrite_i , MemtoReg_i , MemWrite_i , MemRead_i , ALUOp_i, ALUSrc_i , inst_i , Imm_i , Rd1_i , Rd2_i , clk_i
		- Outputs: RegWrite_o , MemtoReg_o , MemWrite_o , MemRead_o , ALUOp_o, ALUSrc_o , inst_o , Imm_o , Rd1_o , Rd2_o
		- **Note unlike the graph in spec, all instruction bits was passed together in inst_o for simplicity.**

1. PipeRegEXMEM
	- Register between EX and MEM stage.
	- The module takes 8 inputs, simply forwarding all of them to outputs (except clk_i), and only changes upon posedge of clk_i.
	- The inputs and outputs are listed below:
		- Inputs: RegWrite_i , MemtoReg_i , MemWrite_i , MemRead_i , rd_i , MuxResult_i , ALUResult_i , clk_i
		- Outputs: RegWrite_o , MemtoReg_o , MemWrite_o , MemRead_o , rd_o , MuxResult_o , ALUResult_o

1. PipeRegMEMWB
	- Register between MEM and WB stage.
	- The module takes 6 inputs, simply forwarding all of them to outputs (except clk_i), and only changes upon posedge of clk_i.
	- The inputs and outputs are listed below:
		- Inputs: RegWrite_i , MemtoReg_i , rd_i , Rs1_i , Rs2_i , clk_i
		- Outputs: RegWrite_o , MemtoReg_o , rd_o , Rs1_o , Rs2_o

1. Sign_Extend.v
	- This module takes an 32 bits input(data_i) and extract 12 bits immediate inside it, then outputs a 32 bits value(data_o).
	- The output is set when input changes, its value is sign-extension of the input's immediate (i.e. 20 concatenated bits with same value as most-significant-bit of immediate is padded to beginning).

1. Define.v
	- There is no module in this file, this file defines all the constant used above, giving an easy way to modify all modules' behavior.

1. PipeRegIFID PipeRegIDEX PipeRegEXMEM PipeRegMEMWB
	- The four modules are almost the same as was in Lab1, only a additional DataStall_i port is connected to each pipeline register. The addition was meant to stall all the register when data miss occur.

1. dcache_controller
	- This module connect CPU to cache data, on each clock edge, it sets it state according to the following graph. Which would then mount modifications inside dcache_sram and Data Memory.
	- ![](https://i.imgur.com/pZys6sl.png)
	- Before switching states, the following flags will be set.
		- IDLE: As nothing need to be done in the state, set all flag to False.
			- mem_enable  <- False
			- mem_write   <- False
			- cache_write <- False
			- write_back  <- False
		- MISS: Since not yet decide which miss is, the flags stay the same.
			- mem_enable  <- False
			- mem_write   <- False
			- cache_write <- False
			- write_back  <- False
		- WRITE BACK: The data on cache that is going to be replaced is dirty, so a memory write back will take place.
			- mem_enable  <- True // Need to access memory.
			- mem_write   <- True // Need to write to memory.
			- cache_write <- False // Cache content stay the same.
			- write_back  <- True 
		- READ MISS: CPU tries to read data that are not cached yet, so we need to read the data from memory.
			- mem_enable  <- True // Need to read.
			- mem_write   <- False // Read only
			- cache_write <- False // Need to wait memory for data.
			- write_back  <- False
		- READ MISS OK: Data required is ready, so no more memory access needed.
			- mem_enable  <- False // Data ready
			- mem_write   <- False // Not modifying
			- cache_write <- True // Write the required data back to cache.
			- write_back  <- False 

1. dcache_sram
	- This module used to store the data and tags of specific address, with least-recent-used policy.
	- I use a bit for every entry to memorize which is the register to replace data(as this is a two-associative cache, one bit suffices).

1. testbench.v
	- This module is provided by TAs, the only modification was initialization of my pipeline registers and some reg in Registers.v as well as Data_Memory.v modules to match the sample output.

## How to run
    - sh run.sh (1|2|3|4, index of testdata)
    - This will auto copy input instructions from "testdata" to "codes", and execute the cpu.
