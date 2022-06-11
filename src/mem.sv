import nes_cpu_pkg::*;

module mem_t
(
    input logic clk_i,
    input logic rstn_i,

    input logic [MEM_ADDR_SIZE-1:0] addr_i,
    input logic [`BYTE-1:0] data_i,
    output logic [(`BYTE*3)-1:0] data_o
);

    logic [`BYTE-1:0] memory_array [(2**MEM_ADDR_SIZE)-1];    

    always_ff @(posedge clk_i) begin
        // No reset
        if (rstn_i) begin
            // Write a byte
            memory_array[addr_i] <= data_o;
        end
    end

    logic [(`BYTE*3)-1:0] data;

    always_comb begin
        // No reset
        if (rstn_i) begin
            // Read 3 bytes
            data = memory_array[addr_i];
        end
    end

    initial begin
        for (int i = 0; i < (2**MEM_ADDR_SIZE)-1; i++) begin
            memory_array[i] = $random();
        end
    end

    assign data_o = data;

endmodule : mem_t
