module cpu_t
(
    input logic clk_i,
    input logic rstn_i,

    input [(3*`BYTE)-1:0] mem_data_i,

);

    // mux PC
    // TODO not needed yet?

    // PC
    logic taken_branch;
    logic [MEM_ADDR_SIZE-1:0] new_pc, pc_q;
    pc_t pc
    #(INCREMENT=3)
    (
        .clk_i(clk_i),
        .rstn_i(rstn_i),

        .block_pc_i(cpu_ctrl_block_pc),

        .taken_branch_i(taken_branch),
        .new_pc_i(new_pc),
        .pc_o(pc_q)

    );

    // fetch
    logic [MEM_ADDR_SIZE-1:0] fe_mem_addr;
    logic [(2*`BYTE)-1:0] fe_data;
    logic [`BYTE-1:0] fe_instr;
    fetch_t fetch
    (
        .clk_i(clk_i),
        .rstn_i(rstn_i),

        .instr_addr_i(pc_q),

        .mem_addr_o(mem_addr),

        .data_i(mem_data_i),

        // To decode
        .data_o(data),
        .instr_o(instr),

    );

    // decode
    reg_id_t dec_dst_reg_addr, dec_src_reg_addr;
    addressing_mode_t dec_addressing_mode;
    logic dec_we;
    ctrl_mux_A_t dec_ctrl_mux_A;
    ctrl_mux_B_t dec_ctrl_mux_B;
    alu_op_t dec_alu_op;
    logic [(2*`BYTE)-1:0] dec_imm;
    decoder_t decoder
    (
        .clk_i(clk_i),
        .rstn_i(rstn_i),

        .opcode_i(fe_instr),
        .data_i(fe_data),

        .src_reg_addr_o(dec_src_reg_addr),
        .dst_reg_addr_o(dec_dst_reg_addr),
        .we_o(dec_we),

        .addressing_mode_o(dec_addr_mode)

        .ctrl_mux_A(dec_ctrl_mux_A),
        .ctrl_mux_B(dec_ctrl_mux_B),

        .imm_o(dec_imm),

        .alu_op_o(dec_alu_op)
    );

    /*
     * mux_A and mux_B are the muxes controlling
     * the sources A and B of the ALU.
     *
     * The control of these muxes depends on another extra mux
     * controlled by the CPU control, to force control values
     * to fetch the operand for the addressing modes.
     *
     */

    // mux_A
    logic [(2*`BYTE)-1:0] out_data_mux_A;
    always_comb begin : mux_A
        case (ctrl_mux_A)
            IMMEDIATE_SRC: out_data_mux_A = imm;
            RES_FROM_ALU_SRC: out_data_mux_A = alu_res_q;
            default: out_data_mux_A = 16'h0000;
        endcase
    end

    // mux_B
    logic [(2*`BYTE)-1:0] out_data_mux_B;
    always_comb begin : mux_B
        case (ctrl_mux_B)
            REGISTER_SRC: out_data_mux_B = reg_read_data;
            ZERO_SRC: out_data_mux_B = 16'h0000;
            default: out_data_mux_B = 16'h0000;
        endcase
    end

    // Control of muxes A and B, the value is in fact given by another mux
    ctrl_mux_A_t ctrl_mux_A;
    ctrl_mux_B_t ctrl_mux_B;
    always_comb begin : mux_ctrl_mux_A
        // Control mux that controls mux A and B
        case (ctrl_mux_dec_cpu_ctrl)
            FROM_DECODER:begin
                ctrl_mux_A = dec_ctrl_mux_A;
                ctrl_mux_B = dec_ctrl_mux_B;
            end
            FROM_CTRL:begin
                ctrl_mux_A = cpu_ctrl_mux_A;
                ctrl_mux_B = cpu_ctrl_mux_B;
            end
            default:begin
                ctrl_mux_A = dec_ctrl_mux_A;
                ctrl_mux_B = dec_ctrl_mux_B;
            end
        endcase
    end

    alu_op_t out_alu_op;
    always_comb begin : mux_alu_op_dec_ctrl
        case (cpu_ctrl_mux_ALU)
            FROM_DECODER: out_alu_op = dec_alu_op;
            FROM_CTRL: out_alu_op = cpu_ctrl_alu_op;
            default: out_alu_op = ALU_NOP;
        endcase
    end

    // ex
    // TODO Missing branches stuff... (Apart from a hundred other stuff)
    logic [(2*`BYTE)-1:0] alu_res;
    ex_t ex
    (
        .clk_i(clk_i),
        .rstn_i(rstn_i),

        .alu_op_i(out_alu_op),
        .alu_res_o(alu_res)

    );

    // This is used to feed the alu
    logic [(2*`BYTE)-1:0] alu_res_q;
    always_ff @(posedge clk_i, negedge rstn_i) begin
        if (!rstn_i) begin
            alu_res_q <= 16'h0000;
        end
        else begin
            alu_res_q <= alu_res;
        end
    end

    // control
    ctrl_mux_dec_ctrl_t ctrl_mux_dec_cpu_ctrl;
    logic cpu_ctrl_block_pc;
    ctrl_mux_mem_addr_t cpu_ctrl_mux_mem_addr;
    ctrl_mux_mem_we_t cpu_ctrl_mux_mem_we;
    ctrl_mux_A_t cpu_ctrl_mux_A;
    ctrl_mux_B_t cpu_ctrl_mux_B;
    ctrl_mux_dec_ctrl_t cpu_ctrl_ctrl_mux_AB;
    ctrl_mux_dec_ctrl_t cpu_ctrl_mux_RF_wenable;
    logic cpu_ctrl_wenable;
    ctrl_mux_dec_ctrl_t cpu_ctrl_mux_ALU;
    alu_op_t cpu_ctrl_alu;

    ctrl_t cpu_ctrl
    (
        .clk_i(clk_i),
        .rstn_i(rstn_i),

        .addressing_mode_i(dec_addressing_mode),

        .block_pc_o(cpu_ctrl_block_pc),

        .ctrl_mux_mem_addr_o(cpu_ctrl_mux_mem_addr),
        .ctrl_mux_mem_we_o(cpu_ctrl_mux_mem_we),

        .ctrl_mux_A_o(cpu_ctrl_mux_A),
        .ctrl_mux_B_o(cpu_ctrl_mux_A),
        .ctrl_ctrl_mux_AB_o(cpu_ctrl_ctrl_mux_AB),

        .ctrl_mux_RF_wenable_o(cpu_ctrl_mux_RF_wenable),
        .ctrl_wenable_o(ctrl_wenable),

        .ctrl_mux_ALU_o(cpu_ctrl_mux_ALU),
        .alu_op_o(cpu_ctrl_alu)
    );

    // RF DEC/CTRL mux
    logic out_we_mux;
    reg_id_t out_reg_id_mux;
    always_comb begin : rf_dec_ctrl_mux
        if (!rstn_i) begin
            out_we_mux = 1'b0;
        end
        else begin
            case (cpu_ctrl_mux_RF_wenable)
                FROM_DECODER:begin
                    out_we_mux = dec_we;
                    out_reg_id_mux = dec_src_reg_addr;
                end
                FROM_CTRL:begin
                    out_we_mux = cpu_ctrl_we;
                    out_reg_id_mux = cpu_ctrl_src_reg_addr;
                end
                default: out_we_mux = 1'b0;
            endcase
        end
    end

    // register file
    logic [(2*`BYTE)-1:0] reg_read_data;
    rf_t rf
    (
        .clk_i(clk_i),
        .rstn_i(rstn_i),

        .reg_addr_i(out_reg_id_mux),

        .reg_we_i(out_we_mux),
        .reg_data_i(16'h0000), // TODO Whenever I generate data from EX, put it here

        .reg_read_data_o(reg_read_data)
    );

endmodule : cpu_t
