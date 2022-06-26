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
    output logic [`BYTE-1:0] status_reg_o
);

    logic [(2*`BYTE)-1:0] res;
    logic carry;
    logic overflow;
    logic update_status_reg;

    always_comb begin
        if (!rstn_i) begin
            res = 16'h0000;
        end
        else begin
            carry = 0;
            update_status_reg = 0;
            case (alu_op_i)
                ALU_BYPASS_A:       res = op_A_i;
                ALU_BYPASS_B:       res = op_B_i;
                ALU_ADD:            res = op_A_i + op_B_i;
                ALU_ADC:begin
                    carry, res = op_A_i + op_B_i;
                    update_status_reg = 1;
                end
                ALU_ADD_ZEROPAGE:   res = {8'h00, op_A_i[`BYTE-1:0] + op_B_i[`BYTE-1:0]};
                ALU_SUB:            res = op_A_i + op_B_i;
                ALU_OR:             res = op_A_i | op_B_i;
                ALU_XOR:            res = op_A_i ^ op_B_i;
                ALU_AND:            res = op_A_i & op_B_i;
                default:            res = 16'h0000;
            endcase

            logic sA = op_A_i[`BYTE-1];
            logic sB = op_B_i[`BYTE-1];
            logic sres = res[`BYTE-1];
            overflow = (!(sA | sB) & (sA | sres)) | ((sA & sB) & (sA ^ sres));

        end
    end

    assign res_o = res;
    assign status_reg_o = status_reg_i | ((0 << `NEGATIVE) | (overflow << `OVERFLOW) | (0 << `NOT_USED) | (0 << `BREAK) | (0 << `INT_DIS) | (0 << `ZERO) | (carry << `CARRY));
    assign status_reg_we_o = update_status_reg;

endmodule : alu_t
