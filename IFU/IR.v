`timescale 1ns / 1ps

module IR(
input clk,
input rst,
input [31:0]instr,
input EXE_ready,
input valid_to_ir,
input [31:0] pc_reg,
output reg instr_valid,
output reg [31:0]instruction,
output reg [31:0]pc_to_EXE); 

always@(posedge clk or negedge rst)
begin if(~rst) 
      instr_valid <= 1'b0;
      else if(EXE_ready | ~instr_valid)
		instr_valid <= valid_to_ir;
end

always@(posedge clk or negedge rst)
begin if(~rst) 
      instruction <= 32'd0;
      else if(EXE_ready | ~instr_valid)
		instruction <= instr;
end

always@(posedge clk or negedge rst)
begin if(~rst) 
      pc_to_EXE <= 32'd0;
      else if(EXE_ready | ~instr_valid)
		pc_to_EXE <= pc_reg;
end
endmodule
