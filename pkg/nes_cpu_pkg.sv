package nes_cpu_pkg;
   
    parameter int MEM_ADDR_SIZE = 16; // 16 bits to index memory
    parameter int BOOT_ADDR = 0;      // TODO Not really  
    parameter int BYTE = 8;           // 8 bits
    parameter int MAX_INSTR_SIZE = 3; // 3 bytes
    parameter int REG_SIZE = BYTE;

    enum logic [1:0]
    {
        FETCH_OPCODE,
        FETCH_DATA,
        FETCH_VALID
    } fetch_state_t;

    import 6502_ISA_pkg::*;

endpackage : nes_cpu_pkg
