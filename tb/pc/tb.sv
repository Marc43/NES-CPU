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

    logic [MEM_ADDR_SIZE-1:0] new_pc = 0;
    logic taken_branch = 0;

    logic [MEM_ADDR_SIZE-1:0] sampled_pc;

    pc_t pc
    (
        .clk_i (clk),
        .rstn_i (~rst),
        .taken_branch_i (taken_branch),
        .new_pc_i (new_pc),
        .pc_o (sampled_pc)
    );

    initial begin
        @(posedge rst);

        while (sampled_pc != 0) @(posedge clk); // Let the PC overflow 

        for (int i = 0; i < 32; i++) begin
            new_pc = $random();
            taken_branch = ~taken_branch;
            @(posedge clk);
            taken_branch = ~taken_branch;
        end

        $finish();

    end

    assert property (@(posedge clk) taken_branch |-> ##1 (sampled_pc == $past(new_pc, 1)));
    assert property (@(posedge clk) !taken_branch |-> ##1 (sampled_pc == ($past(sampled_pc, 1)-INSTR_SIZE_IN_BYTES)));

endmodule : tb
