module fetch_t
(
    input logic clk_i,
    input logic rstn_i,

    input logic [BYTE-1:0] instr_byte_i,

    output logic [(MAX_INSTR_SIZE*BYTE)-1:0] instr_o,
    output logic [$clog2(MAX_INSTR_SIZE)-1:0] instr_size_o,
    output logic instr_ready_o
);

    /*
     * The fetch can either retrieve
     * instructions of 1, 2 or 3 bytes.
     *
     * To decide how big the instruction is
     * while it is fetching it, it will 
     * require some kind of decoder.
     *
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

endmodule : fetch_t
