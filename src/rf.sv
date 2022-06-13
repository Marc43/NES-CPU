module rf_t
(
    logic clk_i,
    logic rstn_i,
    reg_id_t reg_addr_i,
    logic reg_we_i,
    logic [(2*`BYTE)-1:0] reg_data_i,
    logic [(2*`BYTE)-1:0] reg_read_data_o
);

    logic [`BYTE-1:0] regs_data [5]; // Add a parameter? Rather than FiVe?

    always_ff @(posedge clk_i, negedge rstn_i) begin
        if (rstn_i && reg_we_i) begin
            regs_data[reg_addr_i] <= reg_data_i;
        end
    end

    always_comb begin
        if (!rstn_i) begin
            reg_read_data_o = 16'h0000;
        end
        else begin
            reg_read_data_o = regs_data[reg_addr_i];
        end
    end

endmodule : rf_t
