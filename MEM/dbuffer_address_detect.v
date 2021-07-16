`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:07:47 05/17/2021 
// Design Name: 
// Module Name:    dbuffer_address_detect 
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

`include "../parameter/define.vh"
module dbuffer_address_detect(

input [31:0] address,           //输入地址
input [1:0]  func2,          //用来判断指令类型,func3的最高为在判断时不需要，

input        load,              
input        store,

output       er_load_n,  // load_nonalign load时非对齐
output       er_load_c,  // load_crossborder load时地址越界
output       er_store_n, //store时非对齐
output       er_store_c, //store时地址越界

output       addr_ok ,  //地址无误 
output       load_error //地址有异常，给上一级，告知该地址不需要写到数据相关模块
);

wire error_nonalign_1;
wire error_crossborder_1;
assign error_nonalign_1 = ((!func2[1] &  func2[0] &  address[0])           //half
				         |( func2[1] & !func2[0] & (address[1] | address[0])));//word,地址的后两位只要有一个1则输出1，都是0时无异常
assign error_crossborder_1 = !((`D_BASE_ADDR == address[31:10]) | ((/*`D_BASE_ADDR[21:1]*/21'b0 == address[31:11]) & (address[9:8]==2'b00))); //用基地址与地址高位进行比较，不相等则越界输出1，相等则不越界输出0
						 

assign er_load_n =  error_nonalign_1    & load;
assign er_load_c =  error_crossborder_1 & load;
assign er_store_n = error_nonalign_1    & store;
assign er_store_c = error_crossborder_1 & store;

assign load_error =(error_nonalign_1 | error_crossborder_1 ) & load ;

assign addr_ok = (~(error_nonalign_1 | error_crossborder_1 )) & ( load | store );//地址没有异常


endmodule

/*always @(*)       
 begin
  case(func3)
     3'b000 : error_nonalign <= 1'b0;                               //loadfunc=000或100时是lb和lbu，边界一定对齐。
	 3'b100 : error_nonalign <= 1'b0;
	 3'b001 : begin                                                 //loadfunc=001或101时是lh和lhu，最低位为0时对齐
	             if (address[0]) error_nonalign <= 1'b1;
			     else            error_nonalign <= 1'b0;
			end
	 3'b101 : begin 
	             if (address[0]) error_nonalign <= 1'b1;
			     else            error_nonalign <= 1'b0;
			  end
	 3'b010 : begin                                                 //loadfunc=010时是lw，低两位都为0时对齐
	             if      (address[1:0] == 2'b00) error_nonalign <= 1'b0;
			     else if (address[1:0] == 2'b01) error_nonalign <= 1'b1;
			     else if (address[1:0] == 2'b10) error_nonalign <= 1'b1;
			     else    (address[1:0] == 2'b11) error_nonalign <= 1'b1;
			    end
	 default : error_nonalign <= 1'b0 ;
  endcase
 end */
 