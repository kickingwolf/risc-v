`timescale 1ns / 1ps
module BPU(


input  dec_bxx,
input  dec_jump_offset31,
output bpu_taken);
 
assign bpu_taken = (dec_bxx & dec_jump_offset31);

endmodule
