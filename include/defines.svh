`define BYTE 8

// 76543210
// aaabbbcc

// 10
// cc
`define C_START 0
`define C_END   `C_START+1

// 432
// bbb
`define B_START `C_END+1
`define B_END   `B_START+2

// 765
// aaa
`define A_START `B_END+1
`define A_END   `A_START+2

// STATUS REG
`define CARRY 0
`define ZERO 1
`define INT_DIS 2
`define DEC_MOD 3
`define BREAK 4
`define NOT_USED 5
`define OVERFLOW 6
`define NEGATIVE 7

