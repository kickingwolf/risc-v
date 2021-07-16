module IO(
input clk,
input rst_n,

input address,
input wr_H_rd_L,

input [31:0]datain,
output reg[31:0]dataout,

input [31:0] input_IO,
output reg [31:0] output_IO
);

reg [31:0]input_IO_reg1;
reg [31:0]input_IO_reg2;

always @(posedge clk or negedge rst_n)
	if(!rst_n)
		begin
			input_IO_reg1<=32'b0;
			input_IO_reg2<=32'b0;
		end
	else
		begin
			input_IO_reg1<=input_IO;
			input_IO_reg2<=input_IO_reg1;
		end
		
always @(posedge clk or negedge rst_n)
	if(!rst_n)
		dataout<=32'b0;
	else if(!wr_H_rd_L)
		if(address)
			dataout<=input_IO_reg2;
		else
			dataout<=output_IO;
			
always @(posedge clk or negedge rst_n)
	if(!rst_n)
		output_IO<=32'b0;
	else if(wr_H_rd_L & !address)
		output_IO<=datain;
endmodule
