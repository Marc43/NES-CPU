module fetch_t
(
    input logic clk_i,
    input logic rstn_i,

    // From PC
    input logic [MEM_ADDR_SIZE-1:0] instr_addr_i,

    // From RF
    //input logic [REG_SIZE-1:0] X_i,
    //input logic [REG_SIZE-1:0] Y_i,
    
    // To MEM (TODO ifdef SIMULATION) 
    output logic [MEM_ADDR_SIZE-1:0] mem_addr_o,
    // From MEM
    input logic [(3*`BYTE)-1:0] data_i,

    // To ID
    output logic [(2*`BYTE)-1:0] data_o,
    output logic [`BYTE-1:0] instr_o
);

    import nes_cpu_pkg::*;
    import cpu_6502_ISA_pkg::*;

    assign mem_addr_o = instr_addr_i;
    assign instr_o = data_i[`BYTE-1:0];
    assign data_o = data_i[(3*`BYTE)-1:`BYTE];
    
endmodule : fetch_t
