module ctrl_t
(
    input logic clk_i,
    input logic rstn_i,

    input addressing_mode_t addressing_mode_i,

    // Do not modify PC in intermediate states
    output logic block_pc_o,

    output ctrl_mux_mem_addr_t ctrl_mux_mem_addr,
    output ctrl_mux_mem_we_t ctrl_mux_mem_we,

    output ctrl_mux_A_t ctrl_mux_A,
    output ctrl_mux_B_t ctrl_mux_B,
    output ctrl_ctrl_mux_AB_t ctrl_ctrl_mux_AB,

    output ctrl_mux_RF_wdata_t ctrl_RF_wdata

);

    ctrl_state_t state;
    ctrl_state_t next_state;

    logic abs_or_ind_ongoing;

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
                    if ((addressing_mode_i == ABSOLUTE) || (addressing_mode_i == ABSOLUTE_X) || (addressing_mode_i == ABSOLUTE_Y)) begin
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

    always_comb begin
        if (!rstn_i) begin
            ctrl_mux_A = RES_FROM_ALU_SRC;
            ctrl_mux_B = ZERO_SRC;
        end
        else begin
            // TODO Check addressing modes again...
            // What is loaded from memory should
            // be available in one of the sources
            // of ALU... Determine in which of both should be
            if (state == EX_FOP1) begin
                // TODO
                ctrl_mux_A =
                ctrl_mux_B =
            end
            else if (state == FOP2) begin
                // TODO
                ctrl_mux_A =
                ctrl_mux_B =
            end
            else begin
                ctrl_mux_A = RES_FROM_ALU_SRC;
                ctrl_mux_B = ZERO_SRC;
            end
        end
    end

    assign abs_or_ind_ongoing = (addressing_mode_i == ABSOLUTE) || (addressing_mode_i == ABSOLUTE_X) || (addressing_mode_i == ABSOLUTE_Y) || (addressing_mode_i == INDIRECT_X) || (addressing_mode_i == INDIRECT_Y);

    assign block_pc_o = (state != FETCH) ? 1'b1 : 1'b0;
    assign ctrl_mux_mem_addr = (state == FETCH) ? PC_FETCH_ADDRESS : ALU_ADDRESS;
    assign ctrl_mux_mem_we = (state == EX_FOP1 || state == EX_IND || state == EX_ABS) ? DECODER_WE : CTRL_WE;

    assign ctrl_ctrl_mux_AB = (((state == EX_FOP1) || (state == FOP2)) && (abs_or_ind_ongoing)) ? FROM_CTRL : FROM_DECODER;

    assign ctrl_RF_wdata = // TODO

endmodule : ctrl_t
