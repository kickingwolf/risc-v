`define CSR_WRITE 2'b01
`define CSR_SET   2'b10
`define CSR_CLEAN 2'b11
`define CSR_NOP   2'b00

`define misa1      32'b10000000100000000001000100000000
`define mvendorid1 32'b0000000000000000000000000001111111
`define marchid1   32'b00101010101010101010101010101010
`define mimpid1    32'd1
`define mhartid1   32'b0

`define IF_stage  2'b01
`define EXE_stage 2'b10
`define MEM_stage 2'b11
`define return0   2'b00
`define BASE      32'd16
`define base_mode 2'b0
`define vector_mode 2'b1