module ctrl_t
(
    input logic clk_i,
    input logic rstn_i,

    input addressing_mode_t addressing_mode_i,
    input logic mem_valid_i,

    // Do not modify PC in intermediate states
    output logic block_pc_o,

    output ctrl_mux_mem_addr_t ctrl_mux_mem_addr_o,
    output ctrl_mux_dec_ctrl_t ctrl_mux_mem_we_o,

    output ctrl_mux_A_t ctrl_mux_A_o,
    output ctrl_mux_B_t ctrl_mux_B_o,
    output ctrl_mux_dec_ctrl_t ctrl_ctrl_mux_AB_o,
    output reg_id_t ctrl_src_reg_addr,

    output ctrl_mux_dec_ctrl_t ctrl_mux_RF_we_o,
    output logic ctrl_we_o,

    output ctrl_mux_dec_ctrl_t ctrl_mux_ALU_o,
    output alu_op_t alu_op_o

);

    ctrl_state_t state;
    ctrl_state_t next_state;

    logic needs_fop_ongoing;
    ctrl_mux_dec_ctrl_t global_mux_dec_ctrl_ctrl;

    always_ff @(posedge clk_i, negedge rstn_i) begin
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
            case (state) 
                FETCH: begin
                    next_state = mem_valid_i ? EX_FOP1 : state;
                end
                EX_FOP1: begin
                    // Needs to fetch operand and memory is not valid
                    if (needs_fop_ongoing && (!mem_valid_i)) begin
                        next_state = EX_FOP1;
                    end
                    // Any of the absolute modes whenever memory is valid
                    else if (needs_fop_ongoing && !((addressing_mode_i == INDIRECT_X) || addressing_mode_i == INDIRECT_Y)) begin
                        next_state = EX_ABS_ZPG;
                    end
                    // Any of the indirect modes whenever memory is valid
                    else if ((addressing_mode_i == INDIRECT_X) || (addressing_mode_i == INDIRECT_Y)) begin
                        next_state = FOP2;
                    end
                    // If instruction didn't depend on FOP, fetch next
                    // instruction
                    else begin
                        next_state = FETCH;
                    end
                end
                FOP2: begin
                    next_state = mem_valid_i ? EX_IND : state;
                end
                EX_IND:     next_state = FETCH;
                EX_ABS_ZPG: next_state = FETCH;
            endcase
        end
    end

    always_comb begin
        if (!rstn_i) begin
            ctrl_mux_A_o = RES_FROM_ALU_SRC;
            ctrl_mux_B_o = ZERO_SRC;
            alu_op_o = ALU_ADD;
        end
        else begin
            //
            //  Absolute:
            //      SRC_REG OP mem[IMMEDIATE] -> DST_REG
            //
            //  Zero page:
            //      SRC_REG OP mem[00(IMMEDIATE+X/Y)] -> DST_REG
            //
            //  Indirect:
            //      SRC_REG OP mem[mem[SRC_REG+X]] -> DST_REG
            //      SRC_REG OP mem[mem[SRC_REG]+Y] -> DST_REG
            //
            if (state == EX_FOP1) begin
                if ((addressing_mode_i == ABSOLUTE) || (addressing_mode_i == ABSOLUTE_X) || (addressing_mode_i == ABSOLUTE_Y)) begin
                    ctrl_mux_A_o = IMMEDIATE_SRC;
                    ctrl_mux_B_o = ZERO_SRC;
                    alu_op_o = ALU_BYPASS_A;
                end
                else if ((addressing_mode_i == ZERO_PAGE)) begin
                    ctrl_mux_A_o = IMMEDIATE_SRC;
                    ctrl_mux_B_o = ZERO_SRC;
                    alu_op_o = ALU_BYPASS_A;
                end
                else if ((addressing_mode_i == ZERO_PAGE_X) || (addressing_mode_i == ZERO_PAGE_Y)) begin
                    ctrl_mux_A_o = IMMEDIATE_SRC;
                    ctrl_mux_B_o = REGISTER_SRC;
                    alu_op_o = ALU_ADD_ZEROPAGE;
                end
                else if ((addressing_mode_i == INDIRECT_X) || (addressing_mode_i == INDIRECT_Y)) begin
                    ctrl_mux_A_o = IMMEDIATE_SRC;
                    ctrl_mux_B_o = REGISTER_SRC;
                    alu_op_o = ALU_ADD;
                end
            end
            // TODO If you prove that this does work, we can just
            // leave it as an else without any condition
            else if (state == FOP2) begin
                if ((addressing_mode_i == INDIRECT_X) || (addressing_mode_i == INDIRECT_Y)) begin
                    ctrl_mux_A_o = IMMEDIATE_SRC;
                    ctrl_mux_B_o = ZERO_SRC;
                    alu_op_o = ALU_BYPASS_A;
                end
            end
            else begin
                ctrl_mux_A_o = IMMEDIATE_SRC;
                ctrl_mux_B_o = ZERO_SRC;
                alu_op_o = ALU_BYPASS_B;
            end
        end
    end

    assign needs_fop_ongoing =  (addressing_mode_i == ABSOLUTE)     || (addressing_mode_i == ABSOLUTE_X)    || (addressing_mode_i == ABSOLUTE_Y)    ||
                                (addressing_mode_i == INDIRECT_X)   || (addressing_mode_i == INDIRECT_Y)    || (addressing_mode_i == ZERO_PAGE)     ||
                                (addressing_mode_i == ZERO_PAGE_X)  || (addressing_mode_i == ZERO_PAGE_Y);

    assign global_mux_dec_ctrl_ctrl = ((state == FETCH) || (((state == EX_FOP1) || (state == FOP2)) && (needs_fop_ongoing))) ? FROM_CTRL : FROM_DECODER;

    // If not fetching, choose 1, which contains zeroes, else, let the incremented PC (PC_Q = PC_D + 3)
    assign block_pc_o = (state != FETCH) ? 1'b1 : 1'b0;
    assign ctrl_mux_mem_addr_o = (state == FETCH) ? PC_FETCH_ADDRESS : ALU_ADDRESS;

    assign ctrl_mux_mem_we_o = global_mux_dec_ctrl_ctrl;
    assign ctrl_ctrl_mux_AB_o = global_mux_dec_ctrl_ctrl;
    assign ctrl_src_reg_addr = ((addressing_mode_i == INDIRECT_X) || (addressing_mode_i == ABSOLUTE_X) || (addressing_mode_i == ZERO_PAGE_X)) ? X_REG: Y_REG;
    assign ctrl_mux_RF_we_o = global_mux_dec_ctrl_ctrl;
    assign ctrl_we_o = 1'b0;
    assign ctrl_mux_ALU_o = global_mux_dec_ctrl_ctrl;

endmodule : ctrl_t
