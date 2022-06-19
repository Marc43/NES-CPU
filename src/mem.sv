import nes_cpu_pkg::*;

module mem_t
(
    input logic clk_i,
    input logic rstn_i,

    input logic [MEM_ADDR_SIZE-1:0] addr_i,
    input logic [`BYTE-1:0] data_i,
    input logic we_i,
    output logic [(`BYTE*3)-1:0] data_o
);

    logic [`BYTE-1:0] memory_array [(2**MEM_ADDR_SIZE)-1];

    always_ff @(posedge clk_i, negedge rstn_i) begin
        if (rstn_i && we_i) begin
            // Write a byte
            memory_array[addr_i] <= data_o;
        end
    end

    logic [(`BYTE*3)-1:0] data;

    always_ff @(posedge clk_i) begin
        // No reset
        if (rstn_i) begin
            // Read 3 bytes
            data <= {memory_array[addr_i+2],
                     memory_array[addr_i+1],
                     memory_array[addr_i+0]};
        end
    end

    initial begin
        logic[`BYTE-1:0] opcodes[];
        // TODO wrap up memory into a wrapper class and create a virtual method 
        // to be overwritten from the tb so we can intialize opcodes array to
        // the set of opcodes we want
        opcodes = new[3];
        opcodes = '{ORA_IMM, ORA_ZPG, ORA_ZPG_X};
        
        for (int i = 0; i < (2**MEM_ADDR_SIZE)-1; i+=3) begin
            memory_array[i] = opcodes[i%opcodes.size()];
            memory_array[i+1] = i+1; // 1, 4, 8, 12, ... (IMM used when computing ZPG points to itself)
            memory_array[i+2] = i+1;
            opcodes.shuffle();
        end
    end

    assign data_o = data;

endmodule : mem_t
