module decoder_t
(
    input logic clk_i,
    input logic rstn_i,

    input logic [`BYTE-1:0] opcode_i,
    input logic [(2*`BYTE)-1:0] data_i,

    output reg_id_t dst_reg_addr_o,
    output logic we_rf_o,
    output logic we_mem_o,

    output reg_id_t src_reg_addr_o,

    output addressing_mode_t addressing_mode_o,

    output ctrl_mux_A_t ctrl_mux_A_o,
    output ctrl_mux_B_t ctrl_mux_B_o,

    output [(2*`BYTE)-1:0] imm_o,

    output alu_op_t alu_op_o

);

    /*
     * The decoder is divided into the
     * groups strategy defined here:
     *
     *  - https://llx.com/Neil/a2/opcodes.html
     *
     */

    addressing_mode_t addressing_mode;
    reg_id_t src_reg_addr;
    reg_id_t dst_reg_addr;
    logic we_rf;
    logic we_mem;

    ctrl_mux_A_t ctrl_mux_A;
    ctrl_mux_B_t ctrl_mux_B;

    alu_op_t alu_op;

    always_comb begin : decode_opcode
        if (!rstn_i) begin
            we_mem = 0;
            we_rf = 0;
        end
        else begin
            // Group one
            if (opcode_i[`C_END:`C_START] == 2'b01) begin
                we_rf = 1;
                we_mem = 0;
                src_reg_addr = A_REG; 
                dst_reg_addr = A_REG;

                case (opcode_i[`B_END:`B_START])
                    G1_IND1_X:  addressing_mode = INDIRECT_X;
                    G1_ZPG:     addressing_mode = ZERO_PAGE;
                    G1_IMM:     addressing_mode = IMMEDIATE;
                    G1_ABS:     addressing_mode = ABSOLUTE;
                    G1_IND2_Y:  addressing_mode = INDIRECT_Y;
                    G1_ZPG_X:   addressing_mode = ZERO_PAGE_X;
                    G1_ABS_Y:   addressing_mode = ABSOLUTE_Y;
                    G1_ABS_X:   addressing_mode = ABSOLUTE_X;
                endcase

                case (opcode_i[`A_END:`A_START])
                    ORA: begin
                        alu_op = ALU_OR;
                    end
                    AND: begin
                        alu_op = ALU_AND;
                    end
                    EOR: begin
                        alu_op = ALU_XOR;
                    end
                    ADC: begin
                        alu_op = ALU_ADC;
                    end
                    STA: begin
                        we_rf = 0;
                        we_mem = 1;

                        // A should contain the @
                        alu_op = ALU_BYPASS_A;
                    end
                    LDA: begin
                        // A should contain the @
                        alu_op = ALU_BYPASS_A;
                    end
                    CMP: begin
                        we_rf = 0;
                        // TODO Maybe the flag modification can be
                        // implicit to the operation, but I need more
                        // experience with the ISA to determine that
                        // (Nope because intermediate ADDS might be done by
                        // ctrl, and these shouldn't affect the flags)
                        // TODO NEED TO DEFINE SPECIFICALLY
                        alu_op = ALU_CMP;
                    end
                    SBC: begin
                        // TODO Maybe the flag modification can be
                        // implicit to the operation, but I need more
                        // experience with the ISA to determine that
                        // (Nope because intermediate ADDS might be done by
                        // ctrl, and these shouldn't affect the flags)
                        // TODO NEED TO DEFINE SPECIFICALLY
                        alu_op = ALU_SUB;
                    end
                endcase

            end
            // Group two
            else if (opcode_i[`C_END:`C_START] == 2'b10) begin

            end
            // Group three
            else if (opcode_i[`C_END:`C_START] == 2'b00) begin

            end
        end
    end

    always_comb begin

        case (addressing_mode) 
            IMMEDIATE:begin
                ctrl_mux_A = IMMEDIATE_SRC;
                ctrl_mux_B = REGISTER_SRC;
            end
            ZERO_PAGE, ABSOLUTE, ZERO_PAGE_X:begin
                ctrl_mux_A = DATA_FROM_MEMORY_SRC;
                ctrl_mux_B = REGISTER_SRC;
            end
            default:begin
                ctrl_mux_A = RES_FROM_ALU_SRC;
                ctrl_mux_B = REGISTER_SRC;
            end

        endcase

    end

    assign addressing_mode_o = addressing_mode;

    // TODO Check that this is really the case it might be {8'h00, data_i[`BYTE-1:0]}, but I am not really sure right now
    logic [(2*`BYTE)-1:0] data;
    assign data = ((addressing_mode == IMMEDIATE) || (addressing_mode == ZERO_PAGE) || (addressing_mode == ZERO_PAGE_X) || (addressing_mode == ZERO_PAGE_Y)) ? {8'h00, data_i[(2*`BYTE)-1:`BYTE]} : data_i;
    assign imm_o = rstn_i ? data : 16'h0000;

    assign ctrl_mux_A_o = ctrl_mux_A;
    assign ctrl_mux_B_o = ctrl_mux_B;

    assign dst_reg_addr_o = dst_reg_addr;
    assign src_reg_addr_o = src_reg_addr;

    assign alu_op_o = alu_op;

    assign we_rf_o = we_rf;
    assign we_mem_o = we_mem;

endmodule : decoder_t
