module rf_t
(
    input logic clk_i,
    input logic rstn_i,
    input reg_id_t reg_addr_i,
    input logic reg_we_i,
    input logic [(2*`BYTE)-1:0] reg_data_i,
    output logic [(2*`BYTE)-1:0] reg_read_data_o
);

    logic [(2*`BYTE)-1:0] reg_read_data;

    logic [`BYTE-1:0] regs_data [5]; // Add a parameter? Rather than FiVe?

    always_ff @(posedge clk_i, negedge rstn_i) begin
        if (rstn_i && reg_we_i) begin
            regs_data[reg_addr_i] <= reg_data_i;
        end
    end

    always_comb begin
        if (!rstn_i) begin
            reg_read_data = 16'h0000;
        end
        else begin
            reg_read_data = regs_data[reg_addr_i];
        end
    end

    assign reg_read_data_o = reg_read_data;

endmodule : rf_t
