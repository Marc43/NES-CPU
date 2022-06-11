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
    input logic [(2*`BYTE)-1:0] data_i,

    // To ID
    output logic [(2*`BYTE)-1:0] data_o,
    output logic [`BYTE-1:0] instr_o,

    // To control
    output fetch_state_t state_o

);

    import nes_cpu_pkg::*;
    import cpu_6502_ISA_pkg::*;

    logic [MEM_ADDR_SIZE-1:0] mem_addr;

    /*
     * This module is only reading everything
     * and forwarding it to the module that 
     * is in charge to determine the addressing mode
     * and change data_o in consequence.
     */

    fetch_state_t state;
    fetch_state_t next_state;

    always_ff @(posedge clk_i) begin : fetch_state_FSM_REG
        if (!rstn_i) begin
            state <= FETCH_OPCODE;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin : fetch_state_FSM_next
        if (!rstn_i) begin
            next_state = FETCH_OPCODE;
        end
        else begin
            if (state == FETCH_OPCODE) begin
                next_state = FETCH_VALID;
            end
            else if (state == FETCH_VALID) begin
                next_state = FETCH_OPCODE;
            end
        end
    end

    // Here I am assuming I can get data from memory every cycle
    // This is not a safe assumption at all, maybe I should have 
    // inputs from memory READY and VALID to indicate if the
    // memory is READY to accept a memory request, and VALID
    // indicating if the requested petition is served or not
    // TBC
    always_comb begin : fetch_state_FSM_outputs
        if (!rstn_i) begin
            instr_o = NOP;
        end
        else begin
            if (state == FETCH_OPCODE) begin
                // PC: 0 | A | - opcode
                // PC: 1 | B | - data byte 0
                // PC: 2 | C | - data byte 1
                mem_addr = instr_addr_i;
            end
            else if (state == FETCH_VALID) begin
                instr_o = data_i[`BYTE-1:0];
                data_o = data_i[(2*`BYTE)-1:`BYTE];
            end
        end
    end

    assign mem_addr_o = mem_addr;
    assign state_o = state;
    
endmodule : fetch_t
