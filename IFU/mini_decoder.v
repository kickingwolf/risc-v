`timescale 1ns / 1ps
module mini_decoder(
input [31:0]instr,
input valid,
output dec_bxx,
output [31:0]dec_jump_offset);

wire [6:0]op = instr[6:0];
//immediate
wire [11:0]bxx_imm = {instr[31],instr[7],instr[30:25],instr[11:8]};
wire [31:0]dec_jump_imm = {{20{bxx_imm[11]}},bxx_imm[11:0]};

					      
assign dec_bxx = (op == 7'b1100011) & valid;							  
assign dec_jump_offset = dec_jump_imm << 1'b1;

					    
endmodule
 