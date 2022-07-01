module ex_t
(
    input logic clk_i,
    input logic rstn_i,

    input logic [(2*`BYTE)-1:0] op_A_i,
    input logic [(2*`BYTE)-1:0] op_B_i,
    input alu_op_t alu_op_i,

    output logic [(2*`BYTE)-1:0] alu_res_o,

    input logic [`BYTE-1:0] status_reg_i,
    output logic [`BYTE-1:0] status_reg_o,
    output logic status_reg_we_o
);

    logic [(2*`BYTE)-1:0] alu_res;
    alu_t alu
    (
        .clk_i(clk_i),
        .rstn_i(rstn_i),

        .op_A_i(op_A_i),
        .op_B_i(op_B_i),
        .alu_op_i(alu_op_i),

        .res_o(alu_res),

        .status_reg_i(status_reg_i),
        .status_reg_o(status_reg_o),
        .status_reg_we_o(status_reg_we_o)
    );

    assign alu_res_o = alu_res;

endmodule : ex_t
