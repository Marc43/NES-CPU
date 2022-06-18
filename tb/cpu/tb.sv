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

    logic [MEM_ADDR_SIZE-1:0] mem_addr;
    logic [(3*`BYTE)-1:0] mem_data_o; // MEM -> CORE

    cpu_t cpu
    (
        .clk_i(clk),
        .rstn_i(~rst),

        .mem_data_i(mem_data_o),

        .mem_addr_o(mem_addr)
    );

    mem_t memory
    (
        .clk_i(clk),
        .rstn_i(~rst),

        .addr_i(mem_addr),
        .data_i(8'h00),

        .data_o (mem_data_o)
    );

    initial begin
        @(negedge rst);

        repeat (50) @(posedge clk);

        $finish();

    end

endmodule : tb
