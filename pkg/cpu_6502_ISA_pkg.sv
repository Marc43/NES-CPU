package cpu_6502_ISA_pkg;

    `include "defines.svh"

    // https://www.middle-engine.com/blog/posts/2020/06/23/programming-the-nes-the-6502-in-detail
    // For addressing modes can be quite useful
    enum logic [2:0]
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

    enum logic [2:0]
    {
        A_REG,
        X_REG,
        Y_REG,
        SP_REG,
        P_REG
    } reg_id_t;

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
    parameter logic [2:0] G1_IND1_ZPG_X = 3'b000;
    parameter logic [2:0] G1_ZPG        = 3'b001;
    parameter logic [2:0] G1_IMM        = 3'b010;
    parameter logic [2:0] G1_ABS        = 3'b011;
    parameter logic [2:0] G1_IND2_ZPG_Y = 3'b100;
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

endpackage : cpu_6502_ISA_pkg
