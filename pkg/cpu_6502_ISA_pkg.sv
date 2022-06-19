package cpu_6502_ISA_pkg;

    `include "defines.svh"

    // https://www.middle-engine.com/blog/posts/2020/06/23/programming-the-nes-the-6502-in-detail
    // For addressing modes can be quite useful
    typedef enum logic [3:0]
    {
        IMPLIED,
        ACCUMULATOR,
        IMMEDIATE,
        ABSOLUTE,
        ABSOLUTE_X,
        ABSOLUTE_Y,
        ZERO_PAGE,
        ZERO_PAGE_X,
        ZERO_PAGE_Y,
        INDIRECT_X, // LDA ($04, X)
        INDIRECT_Y, // LDA ($04), Y
        ABSOLUTE_INDIRECT, // JMP ($1234)
        RELATIVE
    } addressing_mode_t;

    typedef enum logic [2:0]
    {
        A_REG,
        X_REG,
        Y_REG,
        SP_REG,
        P_REG
    } reg_id_t;

    typedef enum logic [2:0]
    {
        FETCH,
        EX_FOP1, // EXECUTE or Fetch Operand 1 (IND/ABS)
        FOP2,    // Fetch Operand 2 (IND)
        EX_ABS_ZPG,
        EX_IND
    } ctrl_state_t;

    // Choose between:
    //  - PC
    //  - ALU computed address
    typedef enum logic
    {
        PC_FETCH_ADDRESS,
        ALU_ADDRESS
    } ctrl_mux_mem_addr_t;

    typedef enum logic [1:0]
    {
        IMMEDIATE_SRC,
        // Both these sources are computed the cycle before,
        // that means that are sent through a FF
        RES_FROM_ALU_SRC, 
        DATA_FROM_MEMORY_SRC
    } ctrl_mux_A_t;

    typedef enum logic
    {
        REGISTER_SRC,
        ZERO_SRC
    } ctrl_mux_B_t;

    // As I use the "EX" to load the data
    // needed by the addressing modes, the
    // CTRL needs to be able to override
    // the control in muxes A and B that
    // choose the source operands of the ALU
    typedef enum logic
    {
        FROM_DECODER,
        FROM_CTRL
    } ctrl_mux_dec_ctrl_t;

    // TODO Remove addressing modes from ALU?
    // Hacer caso A GeGy???
    typedef enum logic [3:0]
    {
        ALU_NOP,
        ALU_BYPASS_A,
        ALU_BYPASS_B,
        ALU_ADD,
        ALU_ADD_ZEROPAGE,
        ALU_SUB,
        ALU_AND,
        ALU_OR,
        ALU_XOR,
        ALU_CMP
    } alu_op_t;

    // Implicit Instructions
    parameter logic [`BYTE-1:0] BREAK = 8'h00;
    parameter logic [`BYTE-1:0] RTI = 8'h40;
    parameter logic [`BYTE-1:0] RTS = 8'h60;

    parameter logic [`BYTE-1:0] PHP = 8'h08;
    parameter logic [`BYTE-1:0] CLC = 8'h18;
    parameter logic [`BYTE-1:0] PLP = 8'h28;
    parameter logic [`BYTE-1:0] SEC = 8'h38;
    parameter logic [`BYTE-1:0] PHA = 8'h48;
    parameter logic [`BYTE-1:0] CLI = 8'h58;
    parameter logic [`BYTE-1:0] PLA = 8'h68;
    parameter logic [`BYTE-1:0] SEI = 8'h78;
    parameter logic [`BYTE-1:0] DEY = 8'h88;
    parameter logic [`BYTE-1:0] TYA = 8'h98;
    parameter logic [`BYTE-1:0] TAY = 8'hA8;
    parameter logic [`BYTE-1:0] CLV = 8'hB8;
    parameter logic [`BYTE-1:0] INY = 8'hC8;
    parameter logic [`BYTE-1:0] CLD = 8'hD8;
    parameter logic [`BYTE-1:0] INX = 8'hE8;
    parameter logic [`BYTE-1:0] SED = 8'hF8;

    parameter logic [`BYTE-1:0] TXA = 8'h8A;
    parameter logic [`BYTE-1:0] TXS = 8'h9A;
    parameter logic [`BYTE-1:0] TAX = 8'hAA;
    parameter logic [`BYTE-1:0] TSX = 8'hBA;
    parameter logic [`BYTE-1:0] DEX = 8'hCA;
    parameter logic [`BYTE-1:0] NOP = 8'hEA;

    // Rest of instructions as in:
    // https://llx.com/Neil/a2/opcodes.html

    // Group One Instructions
    parameter logic [2:0] ORA = 3'b000;
    parameter logic [2:0] AND = 3'b001;
    parameter logic [2:0] EOR = 3'b010;
    parameter logic [2:0] ADC = 3'b011;
    parameter logic [2:0] STA = 3'b100;
    parameter logic [2:0] LDA = 3'b101;
    parameter logic [2:0] CMP = 3'b110;
    parameter logic [2:0] SBC = 3'b111;

    // G1       : Group one
    // IND(1|2) : Indexed one or two
    // ZPG      : Zero page
    // IMM      : Immediate
    // ABS      : Absolute
    parameter logic [2:0] G1_IND1_X     = 3'b000;
    parameter logic [2:0] G1_ZPG        = 3'b001;
    parameter logic [2:0] G1_IMM        = 3'b010;
    parameter logic [2:0] G1_ABS        = 3'b011;
    parameter logic [2:0] G1_IND2_Y     = 3'b100;
    parameter logic [2:0] G1_ZPG_X      = 3'b101;
    parameter logic [2:0] G1_ABS_Y      = 3'b110;
    parameter logic [2:0] G1_ABS_X      = 3'b111;

    // Group Two Instructions
    parameter logic [2:0] ASL = 3'b000;
    parameter logic [2:0] ROL = 3'b001;
    parameter logic [2:0] LSR = 3'b010;
    parameter logic [2:0] ROR = 3'b011;
    parameter logic [2:0] STX = 3'b100;
    parameter logic [2:0] LDX = 3'b101;
    parameter logic [2:0] DEC = 3'b110;
    parameter logic [2:0] INC = 3'b111;

    // G2       : Group two
    // ZPG      : Zero page
    // IMM      : Immediate
    // ABS      : Absolute
    // ACC      : Accumulator
    parameter logic [2:0] G2_IMM     = 3'b000;
    parameter logic [2:0] G2_ZPG     = 3'b001;
    parameter logic [2:0] G2_ACC     = 3'b010;
    parameter logic [2:0] G2_ABS     = 3'b011;
    parameter logic [2:0] G2_ZPG_X   = 3'b101;
    parameter logic [2:0] G2_ABS_X   = 3'b111;

    // Group Three Instructions
    parameter logic [2:0] BIT       = 3'b001;
    parameter logic [2:0] JMP       = 3'b010;
    parameter logic [2:0] JMP_ABS   = 3'b011;
    parameter logic [2:0] STY       = 3'b100;
    parameter logic [2:0] LDY       = 3'b101;
    parameter logic [2:0] CPY       = 3'b110;
    parameter logic [2:0] CPX       = 3'b111;

    // G3       : Group three
    // ZPG      : Zero page
    // IMM      : Immediate
    // ABS      : Absolute
    parameter logic [2:0] G3_IMM   = 3'b000;
    parameter logic [2:0] G3_ZPG   = 3'b001;
    parameter logic [2:0] G3_ABS   = 3'b011;
    parameter logic [2:0] G3_ZPG_X = 3'b101;
    parameter logic [2:0] G3_ABS_X = 3'b111;

    // Full opcodes
    // Using macros here would be nice, but, honestly, I do not really care ;)
    parameter logic [1:0] G1_CC = 2'b01;
    parameter logic [`BYTE-1:0] ORA_IMM =           {ORA, G1_IMM, G1_CC};
    parameter logic [`BYTE-1:0] ORA_ZPG =           {ORA, G1_ZPG, G1_CC};
    parameter logic [`BYTE-1:0] ORA_ZPG_X =         {ORA, G1_ZPG_X, G1_CC};
    parameter logic [`BYTE-1:0] ORA_ABS =           {ORA, G1_ABS, G1_CC};
    parameter logic [`BYTE-1:0] ORA_ABS_X =         {ORA, G1_ABS_X, G1_CC};
    parameter logic [`BYTE-1:0] ORA_ABS_Y =         {ORA, G1_ABS_Y, G1_CC};
    parameter logic [`BYTE-1:0] ORA_INDIRECT_X =    {ORA, G1_IND1_X, G1_CC};
    parameter logic [`BYTE-1:0] ORA_INDIRECT_Y =    {ORA, G1_IND2_Y, G1_CC};

    parameter logic [`BYTE-1:0] AND_IMM =           {AND, G1_IMM, G1_CC};
    parameter logic [`BYTE-1:0] AND_ZPG =           {AND, G1_ZPG, G1_CC};
    parameter logic [`BYTE-1:0] AND_ZPG_X =         {AND, G1_ZPG_X, G1_CC};
    parameter logic [`BYTE-1:0] AND_ABS =           {AND, G1_ABS, G1_CC};
    parameter logic [`BYTE-1:0] AND_ABS_X =         {AND, G1_ABS_X, G1_CC};
    parameter logic [`BYTE-1:0] AND_ABS_Y =         {AND, G1_ABS_Y, G1_CC};
    parameter logic [`BYTE-1:0] AND_INDIRECT_X =    {AND, G1_IND1_X, G1_CC};
    parameter logic [`BYTE-1:0] AND_INDIRECT_Y =    {AND, G1_IND2_Y, G1_CC};

    parameter logic [`BYTE-1:0] EOR_IMM =           {EOR, G1_IMM, G1_CC};
    parameter logic [`BYTE-1:0] EOR_ZPG =           {EOR, G1_ZPG, G1_CC};
    parameter logic [`BYTE-1:0] EOR_ZPG_X =         {EOR, G1_ZPG_X, G1_CC};
    parameter logic [`BYTE-1:0] EOR_ABS =           {EOR, G1_ABS, G1_CC};
    parameter logic [`BYTE-1:0] EOR_ABS_X =         {EOR, G1_ABS_X, G1_CC};
    parameter logic [`BYTE-1:0] EOR_ABS_Y =         {EOR, G1_ABS_Y, G1_CC};
    parameter logic [`BYTE-1:0] EOR_INDIRECT_X =    {EOR, G1_IND1_X, G1_CC};
    parameter logic [`BYTE-1:0] EOR_INDIRECT_Y =    {EOR, G1_IND2_Y, G1_CC};

    parameter logic [`BYTE-1:0] ADC_IMM =           {ADC, G1_IMM, G1_CC};
    parameter logic [`BYTE-1:0] ADC_ZPG =           {ADC, G1_ZPG, G1_CC};
    parameter logic [`BYTE-1:0] ADC_ZPG_X =         {ADC, G1_ZPG_X, G1_CC};
    parameter logic [`BYTE-1:0] ADC_ABS =           {ADC, G1_ABS, G1_CC};
    parameter logic [`BYTE-1:0] ADC_ABS_X =         {ADC, G1_ABS_X, G1_CC};
    parameter logic [`BYTE-1:0] ADC_ABS_Y =         {ADC, G1_ABS_Y, G1_CC};
    parameter logic [`BYTE-1:0] ADC_INDIRECT_X =    {ADC, G1_IND1_X, G1_CC};
    parameter logic [`BYTE-1:0] ADC_INDIRECT_Y =    {ADC, G1_IND2_Y, G1_CC};

    parameter logic [`BYTE-1:0] STA_IMM =           {ADC, G1_IMM, G1_CC};
    parameter logic [`BYTE-1:0] STA_ZPG =           {ADC, G1_ZPG, G1_CC};
    parameter logic [`BYTE-1:0] STA_ZPG_X =         {ADC, G1_ZPG_X, G1_CC};
    parameter logic [`BYTE-1:0] STA_ABS =           {ADC, G1_ABS, G1_CC};
    parameter logic [`BYTE-1:0] STA_ABS_X =         {ADC, G1_ABS_X, G1_CC};
    parameter logic [`BYTE-1:0] STA_ABS_Y =         {ADC, G1_ABS_Y, G1_CC};
    parameter logic [`BYTE-1:0] STA_INDIRECT_X =    {ADC, G1_IND1_X, G1_CC};
    parameter logic [`BYTE-1:0] STA_INDIRECT_Y =    {ADC, G1_IND2_Y, G1_CC};

    parameter logic [`BYTE-1:0] LDA_IMM =           {ADC, G1_IMM, G1_CC};
    parameter logic [`BYTE-1:0] LDA_ZPG =           {ADC, G1_ZPG, G1_CC};
    parameter logic [`BYTE-1:0] LDA_ZPG_X =         {ADC, G1_ZPG_X, G1_CC};
    parameter logic [`BYTE-1:0] LDA_ABS =           {ADC, G1_ABS, G1_CC};
    parameter logic [`BYTE-1:0] LDA_ABS_X =         {ADC, G1_ABS_X, G1_CC};
    parameter logic [`BYTE-1:0] LDA_ABS_Y =         {ADC, G1_ABS_Y, G1_CC};
    parameter logic [`BYTE-1:0] LDA_INDIRECT_X =    {ADC, G1_IND1_X, G1_CC};
    parameter logic [`BYTE-1:0] LDA_INDIRECT_Y =    {ADC, G1_IND2_Y, G1_CC};

    parameter logic [`BYTE-1:0] CMP_IMM =           {ADC, G1_IMM, G1_CC};
    parameter logic [`BYTE-1:0] CMP_ZPG =           {ADC, G1_ZPG, G1_CC};
    parameter logic [`BYTE-1:0] CMP_ZPG_X =         {ADC, G1_ZPG_X, G1_CC};
    parameter logic [`BYTE-1:0] CMP_ABS =           {ADC, G1_ABS, G1_CC};
    parameter logic [`BYTE-1:0] CMP_ABS_X =         {ADC, G1_ABS_X, G1_CC};
    parameter logic [`BYTE-1:0] CMP_ABS_Y =         {ADC, G1_ABS_Y, G1_CC};
    parameter logic [`BYTE-1:0] CMP_INDIRECT_X =    {ADC, G1_IND1_X, G1_CC};
    parameter logic [`BYTE-1:0] CMP_INDIRECT_Y =    {ADC, G1_IND2_Y, G1_CC};

    parameter logic [`BYTE-1:0] SBC_IMM =           {ADC, G1_IMM, G1_CC};
    parameter logic [`BYTE-1:0] SBC_ZPG =           {ADC, G1_ZPG, G1_CC};
    parameter logic [`BYTE-1:0] SBC_ZPG_X =         {ADC, G1_ZPG_X, G1_CC};
    parameter logic [`BYTE-1:0] SBC_ABS =           {ADC, G1_ABS, G1_CC};
    parameter logic [`BYTE-1:0] SBC_ABS_X =         {ADC, G1_ABS_X, G1_CC};
    parameter logic [`BYTE-1:0] SBC_ABS_Y =         {ADC, G1_ABS_Y, G1_CC};
    parameter logic [`BYTE-1:0] SBC_INDIRECT_X =    {ADC, G1_IND1_X, G1_CC};
    parameter logic [`BYTE-1:0] SBC_INDIRECT_Y =    {ADC, G1_IND2_Y, G1_CC};
endpackage : cpu_6502_ISA_pkg
