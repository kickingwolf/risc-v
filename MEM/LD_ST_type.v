`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:09:17 05/17/2021 
// Design Name: 
// Module Name:    LD_ST_type 
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
module LD_ST_type(addr2,func3,store_type,rd_data_wr,wr_data_in,wr_data,rd_final_data_out);

input [1:0]  addr2;
input [2:0]  func3;
input        store_type;
input [31:0] rd_data_wr;
input [31:0] wr_data_in;

output  [31:0]   wr_data;
output  [31:0]    rd_final_data_out;
					//sb
assign wr_data = ({32{ store_type & !func3[2] & !func3[1] & !func3[0]& !addr2[1] & !addr2[0]}} & {rd_data_wr[31:8], wr_data_in[7:0]                    } )     
	                    |({32{ store_type & !func3[2] & !func3[1] & !func3[0]& !addr2[1] &  addr2[0]}} & {rd_data_wr[31:16],wr_data_in[15:8], rd_data_wr [7:0]} )
	                    |({32{ store_type & !func3[2] & !func3[1] & !func3[0]&  addr2[1] & !addr2[0]}} & {rd_data_wr[31:24], wr_data_in[23:16],rd_data_wr[15:0]} )
	                    |({32{ store_type & !func3[2] & !func3[1] & !func3[0]&  addr2[1] &  addr2[0]}} & {                        wr_data_in[31:24],rd_data_wr[23:0]} )
				    //sh
  				        |({32{ store_type & !func3[2] & !func3[1] &  func3[0]& !addr2[1]}} &  { rd_data_wr[31:16],wr_data_in[15:0]})
	                    |({32{ store_type & !func3[2] & !func3[1] &  func3[0]&  addr2[1]}} &  { wr_data_in[31:16],rd_data_wr[15:0]})
				    //sw
	                    |({32{ store_type & !func3[2] &  func3[1] & !func3[0] }} &  wr_data_in) ;
assign rd_final_data_out = ({32{/*!store_type &*/ !func3[2] & !func3[1] & !func3[0]& !addr2[1] & !addr2[0]}} & {{24{rd_data_wr[7]}},rd_data_wr[7:0]}  )
               /*lb*/ |({32{/*!store_type &*/ !func3[2] & !func3[1] & !func3[0]& !addr2[1] &  addr2[0]}} & {{24{rd_data_wr[7]}},rd_data_wr[15:8]} )
	                      |({32{/*!store_type &*/ !func3[2] & !func3[1] & !func3[0]&  addr2[1] & !addr2[0]}} & {{24{rd_data_wr[7]}},rd_data_wr[23:16]} )
	                      |({32{/*!store_type &*/ !func3[2] & !func3[1] & !func3[0]&  addr2[1] &  addr2[0]}} & {{24{rd_data_wr[7]}},rd_data_wr[31:24]} )
					//lbu        	
  				          |({32{/*!store_type &*/  func3[2] & !func3[1] & !func3[0]& !addr2[1] & !addr2[0]}} & {24'b00000000_00000000_00000000,rd_data_wr[7:0]}  )
                          |({32{/*!store_type &*/  func3[2] & !func3[1] & !func3[0]& !addr2[1] &  addr2[0]}} & {24'b00000000_00000000_00000000,rd_data_wr[15:8]} )
	                      |({32{/*!store_type &*/  func3[2] & !func3[1] & !func3[0]&  addr2[1] & !addr2[0]}} & {24'b00000000_00000000_00000000,rd_data_wr[23:16]} )
	                      |({32{/*!store_type &*/  func3[2] & !func3[1] & !func3[0]&  addr2[1] &  addr2[0]}} & {24'b00000000_00000000_00000000,rd_data_wr[31:24]} )
					//lh		
                          |({32{/*!store_type &*/ !func3[2] & !func3[1] &  func3[0]&             !addr2[1]}} & {{16{rd_data_wr[15]}},rd_data_wr[15:0]} )
                          |({32{/*!store_type &*/ !func3[2] & !func3[1] &  func3[0]&              addr2[1]}} & {{16{rd_data_wr[31]}},rd_data_wr[31:16]})
					//lhu	     
	                      |({32{/*!store_type &*/  func3[2] & !func3[1] &  func3[0]&             !addr2[1]}} & {16'b0,rd_data_wr[15:0]}   )
	                      |({32{/*!store_type &*/  func3[2] & !func3[1] &  func3[0]&              addr2[1]}} & {16'b0,rd_data_wr[31:16]}  )
					//lw
				          |({32{/*!store_type &*/ !func3[2] &  func3[1] & !func3[0]                       }} &   rd_data_wr);
							 
endmodule
