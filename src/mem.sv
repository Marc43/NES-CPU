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

//        logic[`BYTE-1:0] opcodes[];
//        // TODO wrap up memory into a wrapper class and create a virtual method 
//        // to be overwritten from the tb so we can intialize opcodes array to
//        // the set of opcodes we want
//        opcodes = '{ORA_IMM, ORA_ZPG, ORA_ZPG_X, AND_IMM, AND_ZPG, AND_ZPG_X, EOR_IMM, EOR_ZPG, EOR_ZPG_X};
//        
//        for (int i = 0; i < (2**MEM_ADDR_SIZE)-1; i+=3) begin
//            memory_array[i] = opcodes[i%opcodes.size()];
//            memory_array[i+1] = i+1; // 1, 4, 7, 0xa, 0xd, ... (IMM used when computing ZPG points to itself)
//            memory_array[i+2] = i+1;
//            opcodes.shuffle();
//        end


        automatic int i = 0;

        memory_array[i] = ORA_IMM; // <--- load FF in A
        memory_array[i+1] = 8'hff;
        memory_array[i+2] = 8'hff;
        /////////////////////////
        memory_array[i+3] = AND_IMM; // <--- FF & FF -> A(FF) 
        memory_array[i+4] = 8'hff;
        memory_array[i+5] = 8'hff;
        /////////////////////////
        memory_array[i+6] = EOR_IMM; // <--- FF ^ FF -> A(00)
        memory_array[i+7] = 8'hff;
        memory_array[i+8] = 8'hff;
        /////////////////////////
        memory_array[i+9] = ORA_IMM; // <--- 00 | 01 -> A(01)
        memory_array[i+10] = 8'h01;
        memory_array[i+11] = 8'h01;
        ////////////////////////
        memory_array[i+12] = AND_ZPG; // MEM[01] & A(01) -> A(01)
        memory_array[i+13] = 8'h01;
        memory_array[i+14] = 8'h01;
        ////////////////////////
        memory_array[i+15] = ORA_ABS; // MEM[0005] & A(01) -> A(FF)
        memory_array[i+16] = 8'h05;
        memory_array[i+17] = 8'h00;
        ////////////////////////
        memory_array[i+18] = AND_IMM; // <---- 00 & A(xx) -> A(00)
        memory_array[i+19] = 8'h00;
        memory_array[i+20] = 8'h00;
        ////////////////////////
        memory_array[i+21] = ADC_IMM; // <---- 00 + A(00) -> A(00) (flag zero set)
        memory_array[i+22] = 8'h00;
        memory_array[i+23] = 8'h00;
        ////////////////////////
        memory_array[i+24] = ADC_IMM; // <---- 00 + A(00) -> A(00) (flag zero not set)
        memory_array[i+25] = 8'hff;
        memory_array[i+26] = 8'hff;
        ////////////////////////
        memory_array[i+27] = ADC_IMM; // <---- 00 + A(00) -> A(00) (flag carry and ovf set)
        memory_array[i+28] = 8'h01;
        memory_array[i+29] = 8'hff;

    end

    assign data_o = data;



endmodule : mem_t


