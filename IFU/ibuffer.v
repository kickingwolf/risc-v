`timescale 1ns / 1ps
module ibuffer(

	input clk,
	input rst,
	input req_vld,  
	input wr_H_rd_L,//ram_ed_wr_en
	input [12:0]wraddr,
   input [63:0]wrdata,	//ram_input_data 
	input [31:0]pc,
	input rdy,
	
	output reg [31:0]pc_reg,
	output reg valid,
	output [31:0]instr);

	reg [31:0]instr_reg;
	wire [63:0]spo;
	
	wire en_valid = rdy | ~valid;
   always@(posedge clk or negedge rst) begin
	    if(~rst) valid <= 1'b0;
		 else if (en_valid) valid <= req_vld; 
	end
	
	wire rd_RAM_en = req_vld & ((pc[15:3] != pc_reg[15:3]) | ~pc[2]) & (en_valid);
	reg rd_RAM_en_dl;
	always@(posedge clk or negedge rst) begin
	    if(~rst) rd_RAM_en_dl<=1'b0;
		 else rd_RAM_en_dl <= rd_RAM_en; 
	end 
	
	always @ (posedge clk or negedge rst)
	begin if(~rst) pc_reg <= 32'd0;
	      else if(en_valid) pc_reg <= pc;//reg pc
	end

	always @ (posedge clk or negedge rst)
	begin if(~rst) instr_reg <= 32'd0;
	      else  if(rd_RAM_en_dl) instr_reg <=  spo[63:32];
	end

	assign instr = (pc == 0) ? 32'd0 :
	               (~pc_reg[2]) ? spo[31:0] :
	               (pc_reg[2] & rd_RAM_en_dl) ? spo[63:32] : instr_reg;
	
	wire [12:0]ram_addr = (wr_H_rd_L) ? wraddr : pc[15:3];

sram_buffer SRAM_buffer (
  .addra(ram_addr),  
  .dina(wrdata), 
  .ena(rst),//sram_enabled
  .clka(clk), // input clk
  .wea(wr_H_rd_L),//wr_rd_en 
  .douta(spo) // output [63 : 0] spo
);	

endmodule
