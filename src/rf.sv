module rf_t
(
    input logic clk_i,
    input logic rstn_i,
    input reg_id_t reg_addr_i,
    input logic reg_we_i,
    input logic [`BYTE-1:0] reg_data_i,
    output logic [`BYTE-1:0] reg_read_data_o,

    input logic status_reg_we_i,
    input logic [`BYTE-1:0] status_reg_i,
    output logic [`BYTE-1:0] status_reg_o
);

    logic [`BYTE-1:0] reg_read_data;

    logic [`BYTE-1:0] regs_data [5]; // Add a parameter? Rather than FiVe?
    logic [`BYTE-1:0] status_reg;

    always_ff @(posedge clk_i, negedge rstn_i) begin
        if (!rstn_i) begin
            for (int i = 0; i < 5; i++) begin
                regs_data[i] <= 8'h00;
            end
            status_reg <= 8'h00;
        end

        if (rstn_i && reg_we_i) begin
            regs_data[reg_addr_i] <= reg_data_i;
        end

        if (rstn_i && status_reg_we_i) begin
            status_reg <= status_reg_i;
        end
    end

    always_comb begin
        if (!rstn_i) begin
            reg_read_data = 8'h00;
        end
        else begin
            reg_read_data = regs_data[reg_addr_i];
        end
    end

    assign reg_read_data_o = reg_read_data;
    assign status_reg_o = status_reg;

endmodule : rf_t
