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
