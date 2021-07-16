`timescale 1ns / 1ps
module ifu(
input clk,  
input rst,
input EXE_ready,
input wr_rd,
input EXE_flush,
input [31:0]EXE_flush_addr,
input INT_flush,
input [31:0]INT_flush_addr,
input INT_PC_reload,
output [31:0]pc_to_EXE, 
output instr_valid,
output [31:0]instruction,
output addr_unaligned,
output [31:0]PC);

wire IR_ready;
wire req_valid;
wire valid_to_ir;
wire [31:0]instr; 
wire bpu_taken;
wire valid;
wire [31:0]pc_reg;

PC_Generator upc(.clk(clk),
                 .rst(rst), 
				     .instr(instr),
				     .instr_valid(instr_valid),
					  .valid_to_ir(valid_to_ir),
				     .EXE_ready(EXE_ready),
				     .EXE_flush(EXE_flush),
                 .EXE_flush_addr(EXE_flush_addr),
                 .INT_flush(INT_flush),
                 .INT_flush_addr(INT_flush_addr),
				     .PC(PC),
				     .IR_rdy(IR_ready),
				     .req_vld(req_valid),
				     .valid(valid),
					  .INT_PC_reload(INT_PC_reload),
				     .addr_unaligned(addr_unaligned));


ibuffer ubuffer(.clk(clk),
                .rst(rst),
					 .wr_H_rd_L(wr_rd),
					 .wraddr(),
					 .wrdata(),
					 .rdy(IR_ready),
					 .req_vld(req_valid),
					 .pc_reg(pc_reg),
					 .pc(PC),
					 .instr(instr),
					 .valid(valid));


IR uir(.clk(clk),
       .rst(rst),
		 .instr(instr),
		 .instruction(instruction),
		 .valid_to_ir(valid_to_ir),
		 .instr_valid(instr_valid),
		 .pc_reg(pc_reg),
		 .pc_to_EXE(pc_to_EXE),
		 .EXE_ready(EXE_ready));
		 
endmodule
