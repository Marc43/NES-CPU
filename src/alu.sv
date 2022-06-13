module alu_t
(
    input logic clk_i,
    input logic rstn_i,

    input logic [(2*`BYTE)-1:0] op_A_i,
    input logic [(2*`BYTE)-1:0] op_B_i,
    input logic alu_op_t alu_op_i,

    output logic [(2*`BYTE)-1:0] res_o
);

    logic [(2*`BYTE)-1:0] res;

    always_comb begin
        if (!rstn_i) begin
            res = 16'h0000;
        end
        else begin
            case (alu_op_i)
                ALU_BYPASS_A:       res = op_A_i;
                ALU_BYPASS_B:       res = op_B_i;
                ALU_ADD:            res = op_A_i + op_B_i;
                ALU_ADD_ZEROPAGE:   res = {8'h00, op_A_i[`BYTE-1:0] + op_B_i[`BYTE-1:0]};
                default:            res = 16'h0000;
            endcase

        end
    end

    assign res_o = res;

endmodule : alu_t
