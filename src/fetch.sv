module fetch_t
(
    input logic clk_i,
    input logic rstn_i,

    input logic [BYTE-1:0] instr_byte_i,

    // TODO Needs inputs of registers X, Y 
    // for the indirect modes, those should
    // be obtained directly from the
    // register file.

    output logic [(MAX_INSTR_SIZE*BYTE)-1:0] instr_o,
    output logic [$clog2(MAX_INSTR_SIZE)-1:0] instr_size_o,
    output logic instr_valid_o

    output logic [(2*BYTE)-1:0] data_o,
    output logic [$clog2(2)-1:0] data_size_o,
    output logic data_valid_o

);

    /*
     * The fetch can either retrieve 1, 2 or 3 bytes.
     *
     * The opcode is always the first to be fetched, and it
     * can be followed by 1 or 2 bytes of data.
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
            if (

        end
    end

    always_comb begin : fetch_state_FSM_outputs
        if (!rstn_i) begin
            instr_o = NOP;
            instr_size_o = 1;
            instr_ready_o = 0;
        end
        else begin
            if (state == FETCH_INSTR_READY) begin
                instr_ready_o = 1;
            end
        end
    end

    // TODO This module does not exist
    // TODO The signals connected do not exist either
    decode_addressing_mode_t decoder
    (
        .clk_i (clk_i),
        .rstn_i (rstn_i),

        .instr_i (...),
        
        .addressing_mode_o (addressing_mode)
    );
    
endmodule : fetch_t
