import nes_cpu_pkg::*;

module tb();

    logic clk = 0;
    logic rst = 1;

    localparam CLK_PERIOD = 10;
    localparam RST_COUNT = 10;

    always begin
        clk = #(CLK_PERIOD/2) ~clk;
    end

    initial begin
        rst = 1;
        #(RST_COUNT*CLK_PERIOD);
        @(posedge clk);
        rst = 0;
    end

    logic [MEM_ADDR_SIZE-1:0] instr_addr;
    logic [MEM_ADDR_SIZE-1:0] mem_addr;
    logic [(3*`BYTE)-1:0] data_input; // from memory always 3 bytes

    // split into:
    //  - 2 data bytes 
    //  - 1 opcode byte
    logic [(2*`BYTE)-1:0] data_output; 
    logic [`BYTE-1:0] instr_output;

    fetch_state_t state;

    pc_t #(3) pc
    (
        .clk_i (clk),
        .rstn_i (~rst),
        .taken_branch_i (1'b0),
        .new_pc_i (8'h00),
        .pc_o (instr_addr)
    );

    fetch_t fetch
    (
        .clk_i (clk),
        .rstn_i (~rst),

        // PC (Pues vaya nombre le has puesto chaval)
        .instr_addr_i (instr_addr),

        // Data fetched from memory
        .data_i (data_input),

        // Address to memory
        .mem_addr_o (mem_addr),

        // Instruction and data to datapath
        .data_o (data_output),
        .instr_o (instr_output),

        // State in case it needs to be used
        // by control 
        .state_o (state)
    );

    mem_t memory
    (
        .clk_i (clk),
        .rstn_i (~rst),

        .addr_i (instr_addr),
        .data_i (8'b0),
        .data_o (data_input)
    );

    initial begin
        @(negedge rst);

        repeat (100) begin
            @(posedge clk);
        end

        $finish();

    end

endmodule : tb
