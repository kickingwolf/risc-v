`timescale 1ns / 1ps

module DFF32(
input [31:0]datain,
input clk,
input rst,
input en,
output reg[31:0]dataout);


always@(posedge clk or negedge rst) begin 
  if (~rst) dataout <= 32'd0;
  else if(en) dataout <= datain;
end

endmodule
