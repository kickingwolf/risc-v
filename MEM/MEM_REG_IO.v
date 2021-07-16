module MEM_REG_IO(clk,rst_n,load_to_bf,store_to_bf,addr_to_bf,fifo_empty,wr_data, fifo_rd_en,rd_data_wr,out_wr_reg,Srouce
,extral_interrupt,soft_interrupt,time_interrupt,input_IO,output_IO);

input clk;
input rst_n;
input load_to_bf;
input store_to_bf;
input [31:0] addr_to_bf;
input [31:0] wr_data;
input fifo_empty;

output fifo_rd_en;
output [31:0]rd_data_wr;
output reg out_wr_reg;

input [14:0]Srouce;
output extral_interrupt;

output soft_interrupt;
output time_interrupt;

input  [31:0]input_IO;
output [31:0]output_IO;


//***********************************************************************************************完成了读写的时序功能he 写寄存器的使�

wire wr_H_rd_L; 
reg wr_sram_en;								 
assign read = ~(load_to_bf | store_to_bf) ;	

always @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
		wr_sram_en <=0;
		else
		wr_sram_en <= store_to_bf & !fifo_rd_en;//写的使能比读完一个周�且一次访存完成时会置�
	end

always @(posedge clk or negedge rst_n)//完成读，写寄存器使能
	begin
		if(~rst_n)
		out_wr_reg <=0;
		else 
		out_wr_reg <= load_to_bf & !fifo_rd_en;//与上面同理，即下个周期会置零
	end
			
assign wr_H_rd_L = ~read & wr_sram_en; 

//******************************************************************************

assign fifo_rd_en =  ( wr_sram_en | out_wr_reg ) & (~fifo_empty);




wire SRAM_mark,reg1_mark,reg2_mark,IO_mark;
wire wr_H_rd_L1,wr_H_rd_L2,wr_H_rd_L3,wr_H_rd_L4;

assign SRAM_mark = ( addr_to_bf[31:10] == 22'b0 );
assign reg1_mark = ( addr_to_bf[10] == 1'b1 ) && ( addr_to_bf[7:6] == 2'b00 );
assign reg2_mark = ( addr_to_bf[10] == 1'b1 ) && ( addr_to_bf[7:6] == 2'b01 );
assign IO_mark   = ( addr_to_bf[10] == 1'b1 ) && ( addr_to_bf[7:6] == 2'b10 );

assign wr_H_rd_L1 = wr_H_rd_L && SRAM_mark;
assign wr_H_rd_L2 = wr_H_rd_L && reg1_mark;
assign wr_H_rd_L3 = wr_H_rd_L && reg2_mark;
assign wr_H_rd_L4 = wr_H_rd_L && IO_mark  ;

wire [31:0]rd_data_wr1,rd_data_wr2,rd_data_wr3,rd_data_wr4;


assign rd_data_wr = ( {32{SRAM_mark}} & rd_data_wr1 )
		    	   |( {32{reg1_mark}} & rd_data_wr2 )
				   |( {32{reg2_mark}} & rd_data_wr3 )
				   |( {32{IO_mark}}   & rd_data_wr4 );

//以下四个模块为四个存储单元，在不同的地址下访问不同的单元，第一个为数据buffer，第二reg1和第三reg2�**，第四个为IO
//******************************** IP_RAM ********************************************			  					  
dbf_sramip1 sram_u( 
  .addra(addr_to_bf[9:2]),  
  .dina(wr_data), 
  .ena(rst_n),
  .clka(clk), 
  .wea(wr_H_rd_L1),
  .douta(rd_data_wr1) 
);	
//********************************* reg1 **********************************************
/* reg11 reg11u(
.clk(clk),
.rst_n(rst_n),
.address(addr_to_bf[4:2]),
.wr_H_rd_L(wr_H_rd_L2),
.load(load_to_bf),
.datain(wr_data),
.dataout(rd_data_wr2)
); */
plic reg1
(
.src(Srouce),

.clk(clk),
.rst_n(rst_n),

.wr_H_rd_L(wr_H_rd_L2),
.load(load_to_bf),

.wdata(wr_data),
.addr(addr_to_bf[4:2]),
.rdata(rd_data_wr2),
.irq(extral_interrupt)
);

//********************************* reg2 **********************************************
/* reg11 reg11u(
.clk(clk),
.rst_n(rst_n),
.address(addr_to_bf[5:2]),
.wr_H_rd_L(wr_H_rd_L3),
.load(load_to_bf),
.datain(wr_data),
.dataout(rd_data_wr3)
); */
CLINT reg2(
.clk(clk),
.rst_n(rst_n),

.wr_H_rd_L(wr_H_rd_L3),
.load(load_to_bf),
.addr(addr_to_bf[5:2]),
.wdata(wr_data),
.rdata(rd_data_wr3),

.time_interrupt(time_interrupt),
.msip_reg(soft_interrupt)
);

//*********************************  IO  **********************************************
/* IO IOu(
.clk(clk),
.rst_n(rst_n),
.address(addr_to_bf[2]),
.wr_H_rd_L(wr_H_rd_L4),
.datain(wr_data),
.dataout(rd_data_wr4)
); */
IO reg3(
.clk(clk),
.rst_n(rst_n),

.address(addr_to_bf[2]),
.wr_H_rd_L(wr_H_rd_L4),

.datain(wr_data),
.dataout(rd_data_wr4),

.input_IO(input_IO),
.output_IO(output_IO)
);

		   		   
endmodule