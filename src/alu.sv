    import nes_cpu_pkg::*;
    import cpu_6502_ISA_pkg::*;

    module alu_t
    (
        input logic clk_i,
        input logic rstn_i,

        input logic [(2*`BYTE)-1:0] op_A_i,
        input logic [(2*`BYTE)-1:0] op_B_i,
        input alu_op_t alu_op_i,

        output logic [(2*`BYTE)-1:0] res_o,

        input logic [`BYTE-1:0] status_reg_i,
        output logic [`BYTE-1:0] status_reg_o,
        output logic status_reg_we_o
    );

        logic [`BYTE:0] res;
        logic carry;
        logic overflow;
        logic zero;
        logic negative;
        logic update_status_reg;

        logic sA;
        logic sB;
        logic sres;

        // I have different opcodes to differentiate between
        // operations that update flags and other that do not
        // I could just have some port from the CTRL forcing
        // the write enable of the status register to 0 and
        // compute the flags ALWAYS.
        //
        // Right now, I do not care.

        always_comb begin
            if (!rstn_i) begin
                res = 16'h0000;
            end
            else begin

                // By default value from status register
                carry = status_reg_i[`CARRY];
                overflow = status_reg_i[`OVERFLOW];
                zero = status_reg_i[`ZERO];
                negative = status_reg_i[`NEGATIVE];

                update_status_reg = 0;
                case (alu_op_i)
                ALU_BYPASS_A:       res = op_A_i;
                ALU_BYPASS_B:       res = op_B_i;
                ALU_ADD:            res = op_A_i + op_B_i;
                ALU_ADC:begin
                    res = op_A_i + op_B_i;
                    carry = res[`BYTE];
                    zero = (res[(2*`BYTE)-1:0] == 16'h0000);
                    negative = res[`BYTE-1];
                    update_status_reg = 1;
                end
                ALU_ADD_ZEROPAGE:   res = {8'h00, op_A_i[`BYTE-1:0] + op_B_i[`BYTE-1:0]};
                ALU_SUB:            res = op_A_i + op_B_i;
                ALU_OR:             res = op_A_i | op_B_i;
                ALU_XOR:            res = op_A_i ^ op_B_i;
                ALU_AND:            res = op_A_i & op_B_i;
                default:            res = 16'h0000;
            endcase

            sA = op_A_i[`BYTE-1];
            sB = op_B_i[`BYTE-1];
            sres = res[`BYTE-1];
            overflow = (!(sA | sB) & (sA | sres)) | ((sA & sB) & (sA ^ sres));

        end
    end

    assign res_o = res[(2*`BYTE)-1:0];
    assign status_reg_o = status_reg_i | ((negative << `NEGATIVE) | (overflow << `OVERFLOW) | (0 << `NOT_USED) | (0 << `BREAK) | (0 << `INT_DIS) | (zero << `ZERO) | (carry << `CARRY));
    assign status_reg_we_o = update_status_reg;

endmodule : alu_t
