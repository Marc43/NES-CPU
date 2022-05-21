import nes_cpu_pkg::*;

module pc_t
(

    input logic clk_i,
    input logic rstn_i,

    input logic taken_branch_i,
    input logic [MEM_ADDR_SIZE-1:0] new_pc_i,

    output logic [MEM_ADDR_SIZE-1:0] pc_o

);

    always_ff @(posedge clk_i, negedge rstn_i) begin
        if (rstn_i == 0) begin
            pc_o <= BOOT_ADDR;
        end
        else begin
            if (taken_branch_i) begin
                pc_o <= new_pc_i;
            end
            else begin
                pc_o <= pc_o + INSTR_SIZE_IN_BYTES;              
            end
        end
    end

endmodule : pc_t
