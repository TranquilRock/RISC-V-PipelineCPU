module dcache_sram
(
    clk_i,
    rst_i,
    addr_i,
    tag_i,
    data_i,
    enable_i,
    write_i,
    tag_o,
    data_o,
    hit_o
);
// Module that store data and tags
// Module that store data and tags
// Module that store data and tags
// Module that store data and tags
// Module that store data and tags
// Module that store data and tags

// I/O Interface from/to controller
input              clk_i;
input              rst_i;
input    [3:0]     addr_i;
input    [24:0]    tag_i;
input    [255:0]   data_i;
input              enable_i;
input              write_i;

output   [24:0]    tag_o;
output   [255:0]   data_o;
output             hit_o;


// Memory
// reg               valid [0:15][0:1];    
reg      [24:0]    tag [0:15][0:1];    
reg      [255:0]   data[0:15][0:1];
reg      lru[0:15]; // Since either entry 0 or 1 will be replace, one bit suffice.

integer            i, j;


// Write Data      
// 1. Write hit
// 2. Read miss: Read from memory
always@(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        for (i=0;i<16;i=i+1) begin
            for (j=0;j<2;j=j+1) begin
                tag[i][j] <= 25'b0;
                data[i][j] <= 256'b0;
            end
            lru[i] <= 1'b0;
        end
    end
    if (enable_i && write_i) begin
        // TODO: Handle your write of 2-way associative cache + LRU here
        if (tag[addr_i][0][22:0] == tag_i[22:0]) begin // write hit. what about dirty? -> return the data to output port, so overwrite anyway
            data[addr_i][0] <= data_i;
            lru[addr_i] <= 1'b1;
        end
        else if (tag[addr_i][1][22:0] == tag_i[22:0])begin // write hit. what about dirty?
            data[addr_i][1] <= data_i;
            lru[addr_i] <= 1'b0;
        end
        else begin // write miss
            tag[addr_i][lru[addr_i]] <= tag_i;
            data[addr_i][lru[addr_i]] <= data_i;
            lru[addr_i] = lru[addr_i] == 1'b1 ? 1'b0 : 1'b1;
        end
    end
end

//sram_tag[23] to indicate if dirty
// Read Data      
// TODO: tag_o=? data_o=? hit_o=?
assign tag_o = (enable_i && (tag_i == tag[addr_i][0])) ? tag[addr_i][0] : (enable_i && (tag_i == tag[addr_i][1])) ? tag[addr_i][1] : 25'b0;// ?? Not sure about which tag to return
assign data_o = (enable_i && (tag_i == tag[addr_i][0])) ? data[addr_i][0] : (enable_i && (tag_i == tag[addr_i][1])) ? data[addr_i][1] : 256'b0;
assign hit_o = enable_i ? ((tag_i == tag[addr_i][0] || tag_i == tag[addr_i][1])? 1'b1 : 1'b0) : 1'b0;

endmodule
