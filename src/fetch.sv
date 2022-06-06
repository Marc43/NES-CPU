module fetch_t
(
    input logic clk_i,
    input logic rstn_i,

    // From PC
    input logic [MEM_ADDR_SIZE-1:0] instr_addr_i,

    // From RF
    input logic [REG_SIZE-1:0] X_i,
    input logic [REG_SIZE-1:0] Y_i,
    
    // To MEM (TODO ifdef SIMULATION) 
    output logic [MEM_ADDR_SIZE-1:0] mem_addr_o,
    // From MEM
    input logic [(2*BYTE)-1:0] data_i,

    // To ID
    output logic [(2*BYTE)-1:0] data_o,
    output logic [BYTE-1:0] instr_o,

    // To control
    output logic fetch_state_t state_o

);

    logic instr_addr, data_addr;
    logic instr_d, instr_q; // Needed to compute abs, zero page, indirect modes addresses...

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
                next_state = (addr_mode_needs_mem) ? FETCH_DATA : FETCH_VALID;
            end
            else if (state == FETCH_DATA) begin
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
                instr_addr = instr_addr_i;
                data_addr = 16'hBEEF;
            end
            else if (state == FETCH_DATA) begin
                instr_addr = 16'hBEEF;
                data_addr = ; // FIXME depending on the addressing mode you need to have a different address....
            end
            else begin
                instr_addr = 16'hBEEF;
                data_addr = 16'hDEAD;
            end
        end
    end

    // TODO This module does not exist
    // TODO The signals connected do not exist either
    decoder_t decoder
    (
        .clk_i (clk_i),
        .rstn_i (rstn_i),

        .instr_i (...),
        
        .addressing_mode_o (addressing_mode)
    );

    always_ff @(posedge clk_i) begin : fetched_instr_ff
        if (!rstn_i) begin
            instr_q = NOP;
        end
        else begin
            instr_q <= instr_d;
        end
    end

    assign mem_addr_o = (state == FETCH_OPCODE) ? instr_addr : data_addr;
    
endmodule : fetch_t
