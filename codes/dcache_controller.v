module dcache_controller
(
    // System clock, reset and stall
    clk_i, 
    rst_i,
    
    // to Data Memory interface        
    mem_data_i, 
    mem_ack_i,     
    mem_data_o, 
    mem_addr_o,     
    mem_enable_o, 
    mem_write_o, 
    
    // to CPU interface    
    cpu_data_i, 
    cpu_addr_i,     
    cpu_MemRead_i, 
    cpu_MemWrite_i, 
    cpu_data_o, 
    cpu_stall_o
);
//
// System clock, start
//
input                 clk_i; 
input                 rst_i;

//
// to Data_Memory interface        
//
input    [255:0]      mem_data_i; 
input                 mem_ack_i; 
    
output   [255:0]      mem_data_o; 
output   [31:0]       mem_addr_o;     
output                mem_enable_o; 
output                mem_write_o; 
    
//    
// to CPU interface            
//    
input    [31:0]       cpu_data_i; 
input    [31:0]       cpu_addr_i;     
input                 cpu_MemRead_i; 
input                 cpu_MemWrite_i; 

output   [31:0]       cpu_data_o; 
output                cpu_stall_o; 

//
// to SRAM interface
//
wire    [3:0]         cache_sram_index;
wire                  cache_sram_enable;
wire    [24:0]        cache_sram_tag;
wire    [255:0]       cache_sram_data;
wire                  cache_sram_write;
wire    [24:0]        sram_cache_tag;
wire    [255:0]       sram_cache_data;
wire                  sram_cache_hit;


// cache
wire                  sram_valid;
wire                  sram_dirty;

// controller
parameter             STATE_IDLE         = 3'h0,
                      STATE_READMISS     = 3'h1,
                      STATE_READMISSOK   = 3'h2,
                      STATE_WRITEBACK    = 3'h3,
                      STATE_MISS         = 3'h4;
reg     [2:0]         state;
reg                   mem_enable;
reg                   mem_write;
reg                   cache_write;
wire                  cache_dirty;
reg                   write_back;

// regs & wires
wire    [4:0]         cpu_offset;
wire    [3:0]         cpu_index;
wire    [22:0]        cpu_tag;
wire    [255:0]       r_hit_data;
wire    [22:0]        sram_tag; // 21 or 22??
wire                  hit;
reg     [255:0]       w_hit_data;
wire                  write_hit;
wire                  cpu_req;
reg     [31:0]        cpu_data;

// to CPU interface
assign    cpu_req     = cpu_MemRead_i | cpu_MemWrite_i;
assign    cpu_tag     = cpu_addr_i[31:9];
assign    cpu_index   = cpu_addr_i[8:5];
assign    cpu_offset  = cpu_addr_i[4:0];
assign    cpu_stall_o = ~hit & cpu_req;
assign    cpu_data_o  = cpu_data; 

// to SRAM interface
assign    sram_valid = sram_cache_tag[24]; //from last round
assign    sram_dirty = sram_cache_tag[23];
assign    sram_tag   = sram_cache_tag[22:0];
assign    cache_sram_index  = cpu_index;
assign    cache_sram_enable = cpu_req;
assign    cache_sram_write  = cache_write | write_hit;
assign    cache_sram_tag    = {1'b1, cache_dirty, cpu_tag};    
assign    cache_sram_data   = (hit) ? w_hit_data : mem_data_i;

// to Data_Memory interface
assign    mem_enable_o = mem_enable;
assign    mem_addr_o   = (write_back) ? {sram_tag, cpu_index, 5'b0} : {cpu_tag, cpu_index, 5'b0};
assign    mem_data_o   = sram_cache_data;
assign    mem_write_o  = mem_write;

assign    write_hit    = hit & cpu_MemWrite_i;
assign    cache_dirty  = write_hit;

// TODO: add your code here!  (r_hit_data=...?)
assign r_hit_data = (hit) ? sram_cache_data : 256'b0; // not sure. note sram_cache_data is from the last cache access. 
// read data :  256-bit to 32-bit

always@(cpu_offset or r_hit_data) begin
    // TODO: add your code here! (cpu_data=...?)
    //Only handle address that are 4 bytes aligned.
    // case (cpu_offset)
    //     5'd0:begin
    //         cpu_data = r_hit_data[31:0];
    //     end
    //     5'd4:begin
    //         cpu_data = r_hit_data[63:32];
    //     end
    //     5'd8:begin
    //         cpu_data = r_hit_data[95:64];
    //     end
    //     5'd12:begin
    //         cpu_data = r_hit_data[127:96];
    //     end
    //     5'd16:begin
    //         cpu_data = r_hit_data[159:128];
    //     end
    //     5'd20:begin
    //         cpu_data = r_hit_data[191:160];
    //     end
    //     5'd24:begin
    //         cpu_data = r_hit_data[223:192];
    //     end
    //     5'd28:begin
    //         cpu_data = r_hit_data[255:224];
    //     end
    //     default: 
    //         $fdisplay(32'h8000_0002,"Cache offset not aligned!? %b",cpu_data);
    // endcase
    // TODO Difficulty1 : verilator disallow dynamic slicing????? Solved by +:
    // Problem assign in nonclock ..? <= or =
    cpu_data = r_hit_data[cpu_offset * 8 +: 32];
end


// write data :  32-bit to 256-bit
always@(cpu_offset or r_hit_data or cpu_data_i) begin
    // TODO: add your code here! (w_hit_data=...?)
    //Bug1 need to retain old data.
    w_hit_data = r_hit_data;
    w_hit_data[cpu_offset * 8 +: 32] = cpu_data_i;
end


// controller 
always@(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
        state       <= STATE_IDLE;
        mem_enable  <= 1'b0; // enable operation on mem. Why need?
        mem_write   <= 1'b0; // write to memory
        cache_write <= 1'b0; // write to cache
        write_back  <= 1'b0; // if true, the tag would be from sram
    end
    else begin
        case(state)        
            STATE_IDLE: begin
                if(cpu_req && !hit) begin      // wait for request
                    state <= STATE_MISS;
                end
                else begin
                    state <= STATE_IDLE;
                end
            end
            STATE_MISS: begin
                if(sram_dirty) begin          // write back if dirty
                    // TODO: add your code here! 
                    // hit-> write_i enable_i
                    //Difficulty3 every wire is assigned, what should be done here? Solve -> using controller regs
                    mem_enable <= 1'b1; // cache to mem
                    mem_write <= 1'b1;  // cache to mem
                    cache_write <= 1'b0; // cache is up to date.
                    write_back <= 1'b1; // need the tag from sram.
                    state <= STATE_WRITEBACK;
                end
                else begin                    // write allocate: write miss = read miss + write hit; read miss = read miss + read hit
                    // TODO: add your code here! 
                    // Difficulty 4 where should the write be taken? As long as the signal is set, write will be done by DataMem.
                    mem_enable <= 1'b1; // Take from mem
                    mem_write <= 1'b0;
                    cache_write <= 1'b0; 
                    write_back <= 1'b0; // use cpu's tag
                    state <= STATE_READMISS;
                end
            end
            STATE_READMISS: begin
                if(mem_ack_i) begin            // wait for data memory acknowledge
                    // TODO: add your code here! 
                    mem_enable <= 1'b0; // ready in cache
                    mem_write <= 1'b0; // no write
                    cache_write <= 1'b1; // write to cache(allocate)
                    write_back <= 1'b0; // use cpu's tag
                    state <= STATE_READMISSOK;
                end
                else begin
                    state <= STATE_READMISS;
                end
            end
            STATE_READMISSOK: begin            // wait for data memory acknowledge
                // TODO: add your code here! 
                mem_enable <= 1'b0; // ready in cache
                mem_write <= 1'b0; // no write
                cache_write <= 1'b0; // done
                write_back <= 1'b0; // use cpu's tag
                state <= STATE_IDLE;
            end
            STATE_WRITEBACK: begin // write hit
                if(mem_ack_i) begin            // wait for data memory acknowledge
                    // TODO: add your code here! 
                    //memory ready, write to cache(hit) and 
                    mem_enable <= 1'b1; // ready in cache
                    mem_write <= 1'b0; // no write
                    cache_write <= 1'b0;
                    write_back <= 1'b0; // use cpu's tag
                    state <= STATE_READMISS;
                end
                else begin
                    state <= STATE_WRITEBACK;
                end
            end
            default: begin
                
            end
        endcase
    end
end

//
// SRAM (cache memory part)
//
dcache_sram dcache_sram
(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .addr_i     (cache_sram_index),
    .tag_i      (cache_sram_tag),
    .data_i     (cache_sram_data),
    .enable_i   (cache_sram_enable),
    .write_i    (cache_sram_write),
    .tag_o      (sram_cache_tag),
    .data_o     (sram_cache_data),
    .hit_o      (hit)
);

endmodule
