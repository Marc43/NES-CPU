package nes_cpu_pkg;
   
    parameter int MEM_ADDR_SIZE = 16; // 16 bits to index memory
    parameter int BOOT_ADDR = 0;      // TODO Not really  
    parameter int BYTE = 8;           // 8 bits
    parameter int MAX_INSTR_SIZE = 3; // 3 bytes

    enum logic [1:0]
    {
        FETCH_OPCODE,
        FETCH_ABS_B0,
        FETCH_ABS_B1,
        FETCH_INSTR_READY
    } fetch_state_t;

    // TODO Maybe add an explanation 
    // for all the addressing modes 
    // so I have fast reference here
    enum logic [...]
    {
        IMPLIED,
        ACCUMULATOR,
        IMMEDIATE,
        ABSOLUTE,
        ZERO_PAGE,
        INDIRECT,
        ABSOLUTE_INDIRECT,
        RELATIVE
    } addressing_mode_t;

    enum logic [...]
    {
        A_REG,
        X_REG
        Y_REG,
        SP_REG,
        P_REG
    } reg_id_t;

    parameter logic[BYTE-1:0] NOP = 8'hEA;

endpackage : nes_cpu_pkg
