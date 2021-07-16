`timescale 1ns / 1ps
module PC_Generator(

input clk,
input rst,
input [31:0]instr,
input EXE_ready,
input valid,
input EXE_flush,//flush
input [31:0]EXE_flush_addr,
input INT_flush,
input INT_PC_reload,
input [31:0]INT_flush_addr,

input instr_valid,
output [31:0]PC,  
output valid_to_ir,
output addr_unaligned,
output IR_rdy,
output req_vld);
 
wire dec_bxx;
wire [31:0]dec_jump_offset;
reg [31:0]pc_bxx;
mini_decoder udecoder(
                      .instr(instr),
							 .valid(valid),
                      .dec_bxx(dec_bxx),
				          .dec_jump_offset(dec_jump_offset));


wire  bpu_taken;
BPU ubpu(.bpu_taken(bpu_taken),
		   .dec_bxx(dec_bxx),
		   .dec_jump_offset31(dec_jump_offset[31]));

//buffer_pc
//`ifdef IBUFFER 
wire [31:0]pc_add4 = PC + 3'd4;
wire [31:0]jump_addr = pc_bxx + dec_jump_offset;

wire [31:0]pc_next = (instr_valid & bpu_taken) ? jump_addr : pc_add4;

wire [31:0]pc_next_2 = (EXE_flush) ? EXE_flush_addr :
                       (INT_PC_reload) ? INT_flush_addr : pc_next;
	
assign valid_to_ir = valid & ~(EXE_flush | INT_flush);
assign IR_rdy = ~valid | (~instr_valid | EXE_ready);
assign req_vld = ~(EXE_flush | INT_flush | bpu_taken) & IR_rdy & !addr_unaligned;


/*
//cache_pc
//`elsif ICACHE //{
reg valid1;
always @(posedge clk or negedge rst)
begin if(~rst) valid1 <= 0;
      else valid1 <= valid;		
end
wire [31:0]pc_add4 = valid ? PC + 3'd4 : PC;
wire [31:0]jump_addr = pc_bxx + dec_jump_offset;

wire [31:0]pc_next = (instr_valid & bpu_taken) ? jump_addr : pc_add4;
wire [31:0]pc_next_2 = (EXE_flush) ? EXE_flush_addr :
                       (INT_flush) ? INT_flush_addr : pc_next;	
assign valid_to_ir =req & ~(EXE_flush | INT_flush);
assign IR_rdy = ~valid1 | (~instr_valid | EXE_ready);
assign req_vld = ~(EXE_flush | INT_flush | bpu_taken) & IR_rdy;
reg req;
always @(posedge clk or negedge rst)
begin if(~rst) req <= 0;
      else req <= req_vld;
end
//`endif 
*/
DFF32 udff(.clk(clk),
           .rst(rst),
			  .en(IR_rdy),
			  .dataout(PC),
			  .datain(pc_next_2));
				
always @(posedge clk or negedge rst)
begin if(~rst) pc_bxx <= 0;
      else pc_bxx <= PC;
end
		  
assign addr_unaligned = (PC[1:0] != 00) ? 1'b1:1'b0;

endmodule
