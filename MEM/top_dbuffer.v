`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:23:58 05/19/2021 
// Design Name: 
// Module Name:    top_dbuffer 
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
          
module top_dbuffer(clk,rst_n,func3,rd,in_top_address,data_to_mem,in_top_load,in_top_store,
                   out_wr_reg,o_rd_final_data,out_rd,er_load_n,er_load_c,er_store_n,er_store_c,load_error,full,
				   Srouce,extral_interrupt,soft_interrupt,time_interrupt,input_IO,output_IO);
				   
input clk;
input rst_n; 
input [2:0]  func3; 
input [4:0]  rd; 
input [31:0] in_top_address;
input [31:0] data_to_mem;
input 		 in_top_load;
input        in_top_store;

output 	 out_wr_reg;//输出的写寄存器使能
output [31:0] o_rd_final_data; //输出的数据 
   
output [4:0]  out_rd;

output       er_load_n;  // load_nonalign load时非对齐
output       er_load_c;  // load_crossborder load时地址越界
output       er_store_n; //store时非对齐
output       er_store_c; //store时地址越界

output       load_error;////地址有异常，给上一级，告知该地址不需要写到数据相关模块

output       full;

input [14:0]Srouce;																					//
output extral_interrupt;																		//
output soft_interrupt;																		//
output time_interrupt;																			//
input [31:0]input_IO;																				//
output[31:0]output_IO;																				

wire [31:0]wr_data,rd_data_wr;

wire addr_ok; //地址是无误的
wire [73:0] fifo_in_data,fifo_out_data;
wire fifo_wr_en,fifo_full,fifo_empty,fifo_rd_en;
assign full = fifo_full;
                 //      [73:69]   [68:66]  	[65]	  [64]	                [63:32]             [31:0]  
assign fifo_in_data = {rd[4:0],func3[2:0],in_top_load,in_top_store,in_top_address[31:0],data_to_mem[31:0]};
 
assign fifo_wr_en = !fifo_full & addr_ok;

//******************************************* FIFO *****************************************************************//
DMfifo4 DMfifo4_u (.clk(clk),                                                                                       //
				   .rst_n(rst_n),                                                                                   //
                   .fifo_data_in(fifo_in_data),                                                                     //
                   .fifo_wr_en(fifo_wr_en),                                                                         //
                   .fifo_full(fifo_full),                                                                           //
                   .fifo_data_out(fifo_out_data),                                                                   //
                   .fifo_rd_en(fifo_rd_en),                                                                         //
                   .fifo_empty(fifo_empty));                                                                        //
//******************************************************************************************************************//
wire [31:0] addr_to_bf,data_to_bf;
wire [4:0] out_rd;
wire [2:0] func_to_bf;
wire load_to_bf,store_to_bf;		   

assign addr_to_bf = fifo_out_data[63:32];
assign data_to_bf = fifo_out_data[31:0];
assign out_rd =     fifo_out_data[73:69];
assign func_to_bf = fifo_out_data[68:66];
assign load_to_bf = fifo_out_data[65];
assign store_to_bf = fifo_out_data[64];
 
//wire [`D_BASE_ADDR_WIDTH-1:0] baseaddress; 
wire [1:0]func2;
assign func2 = func3[1:0];
//assign baseaddress = in_top_address[31:32-`D_BASE_ADDR_WIDTH];
//***************************************** DETECT *****************************************************************//
dbuffer_address_detect detect_u1(.address(in_top_address),                                                          //
                                 .func2(func2),                                                                     //
                                 .load(in_top_load),                                                                //
                                 .store(in_top_store),                                                              //
																													//
								 .er_load_n(er_load_n),                                                             //
								 .er_load_c(er_load_c),                                                             //
                                 .er_store_n(er_store_n),                                                           //
                                 .er_store_c(er_store_c),                                                           //
                                 .addr_ok(addr_ok),                                                                 //
								 .load_error(load_error));                                                          //
//******************************************************************************************************************//



//**************************************** 存储体 ******************************************************************//
MEM_REG_IO    MEM_REG_IO_u(.clk(clk),                                                                               //
						   .rst_n(rst_n),                                                                           //
						   .load_to_bf(load_to_bf),                                                                 //
						   .store_to_bf(store_to_bf),                                                               //
						   .addr_to_bf(addr_to_bf),                                                                 //
						   .fifo_empty(fifo_empty),                                                                 //
						   .wr_data(wr_data),                                                                        //
																													//
						   .fifo_rd_en(fifo_rd_en),                                                                 //
						   .rd_data_wr(rd_data_wr),                                                                    //
						   .out_wr_reg(out_wr_reg),																	//
																													//
						   .Srouce(Srouce),																			//
						   .extral_interrupt(extral_interrupt),														//
						   .soft_interrupt(soft_interrupt),															//
						   .time_interrupt(time_interrupt),															//
						   .input_IO(input_IO),																		//
						   .output_IO(output_IO)																	//
);                                                                                                                  //
//******************************************************************************************************************//



//**************************************** TYPE ********************************************************************//
																													//
LD_ST_type	type_u(.addr2(addr_to_bf[1:0]),                                                                         //
                   .func3(func_to_bf),                                                                              //
                   .store_type(store_to_bf),                                                                        //
                   .rd_data_wr(rd_data_wr),//sram de outdata                                                        //
                   .wr_data_in(data_to_bf),                                                                         //
																													//
                   .wr_data(wr_data),//to sram                                                                      //
                   .rd_final_data_out(o_rd_final_data));                                                            //
//------------------------------------------------------------------------------------------------------------------//		


//************************************* RAM ************************************************************************		
/*dbuffer_sram sram_u(.clk(clk),
                    .buffer_csn(rst_n),
                    .buffer_addr(addr_to_bf[9:2]),
                    .buffer_write_en(wr_sram_en),
                    .buffer_read_en(read),
                    .buffer_datain(wr_data),
                    .buffer_dataout(rd_data_wr));*/
endmodule
