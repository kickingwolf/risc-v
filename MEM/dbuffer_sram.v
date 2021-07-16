`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:23:53 05/19/2021 
// Design Name: 
// Module Name:    dbuffer_sram 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "define.vh"
module dbuffer_sram(clk,buffer_csn,buffer_addr,buffer_write_en,buffer_read_en,buffer_datain,buffer_dataout);

input clk;
input buffer_csn;//低电平有效
input[`DBUFFER_SRAM_ADDR_WIDTH-1:0] buffer_addr;
input buffer_write_en;
input buffer_read_en;
input[31:0] buffer_datain;

output [31:0] buffer_dataout;
reg[31:0] buffer_dataout;
reg[31:0] Memory[0:`DBUFFER_SRAM_DEPTH-1];

//------Write operation
always @(posedge clk)
  begin
    if(~buffer_csn && buffer_write_en) 
	  Memory[buffer_addr] <= buffer_datain;
  end
  
//------Read operation mode 1
always @(posedge clk)
  begin
    if(~buffer_csn && buffer_read_en)
	  buffer_dataout <= Memory[buffer_addr];
  end 
  
//------Read operation mode 2
/*always @(*)
  begin
    if(~buffer_csn && buffer_read_en)
	  buffer_dataout <= Memory[buffer_addr];
  end  */

endmodule
