module decode_addressing_mode_t
(
    input logic clk_i,
    input logic rstn_i,

    input logic [BYTE-1:0] opcode_i,

    output addressing_mode_t addressing_mode_o,
    output reg_id_t reg_addr_o

    // TODO Pending THE REST OF SIGNALS.
    // Right now I am only concerned about 
    // the fetch and somehow it depends on
    // the decoded instruction
    //
    // I see that process highly coupled
    // so the decoder will be done 
);

endmodule : decode_addressing_mode_t
