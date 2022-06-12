module ctrl_t
(
    input logic clk_i,
    input logic rstn_i,

    input addressing_mode_t addressing_mode_i,

    output logic block_pc_o,
    // TODO Depending on the stage, the memory takes 
    // the address from one part of the CPU
    output mem_addr_choice_t addr_choice_o

);

    ctrl_state_t state;
    ctrl_state_t next_state;

    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            state <= FETCH;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin
        if (!rstn_i) begin
            next_state = FETCH;
        end
        else begin
            case (state) begin
                FETCH:      next_state = EX_FOP1;
                EX_FOP1: begin
                    if ((addressing_mode_i == ABSOLUTE) || (addressing_mode_i == ABSOLUTE_X) || addressing_mode_i == ABSOLUTE_Y) begin
                        next_state = EX_ABS; 
                    end
                    else if ((addressing_mode_i == INDIRECT_X) || (addressing_mode_i == INDIRECT_Y)) begin
                        next_state = FOP2;
                    end
                    else begin
                        next_state = FETCH;
                    end
                end
                FOP2:       next_state = EX_IND;
                EX_IND:     next_state = FETCH;
                EX_ABS:     next_state = FETCH;
            end
        end
    end

    assign block_pc_o = (state != FETCH) ? 1'b1 : 1'b0;

endmodule : ctrl_t
