package nes_cpu_pkg;
   
    `include "defines.svh"

    import cpu_6502_ISA_pkg::*;

    parameter int MEM_ADDR_SIZE = 16; // 16 bits to index memory
    parameter int BOOT_ADDR = 0;      // TODO Not really  
    parameter int MAX_INSTR_SIZE = 3; // 3 bytes
    parameter int REG_SIZE = `BYTE;

    typedef enum logic 
    {
        FETCH_OPCODE,
        FETCH_VALID
    } fetch_state_t;

endpackage : nes_cpu_pkg
