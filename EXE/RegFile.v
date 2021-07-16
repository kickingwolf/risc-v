module RegFile(input clk,
           input rstn,
		   input [4:0] RS1,
		   input [4:0] RS2,
		   input [4:0] Rd_EXE,
		   input [4:0] Rd_MEM,
		   input [4:0] Rd_MULT,
		   input Wen_EXE,
		   input Wen_MEM,
		   input Wen_MULT,
		   output [31:0] BusA,
		   output [31:0] BusB,
		   input [31:0] BusW_EXE,
		   input [31:0] BusW_MEM,
		   input [31:0] BusW_MULT);
    
	reg [31:0] DataReg[31:0];
	wire DataWen_EXE[31:0];
	wire DataWen_MEM[31:0];
	wire DataWen_MULT[31:0];
	
	//generate register's wen signals
	assign 	DataWen_EXE	[0] = 1'b0;
	assign 	DataWen_MEM	[0] = 1'b0;
	assign  DataWen_MULT[0] = 1'b0;
	genvar i;
	generate for(i=1;i<32;i=i+1) 
	         begin:loop_en_mux
			     assign DataWen_EXE[i] = (Wen_EXE & (Rd_EXE==i));
				 assign DataWen_MEM[i] = (Wen_MEM & (Rd_MEM==i));
				 assign DataWen_MULT[i] = (Wen_MULT & (Rd_MULT==i));
			 end
	endgenerate
	

	//register's writing
	genvar j;
	generate for(j=0;j<32;j=j+1)
	         begin:loop_wr_reg
			     always@(posedge clk or negedge rstn) begin
				     if(~rstn) DataReg[j] <= 32'd0;
                else if(DataWen_EXE[j]) DataReg[j] <= BusW_EXE;
					 else if(DataWen_MULT[j]) DataReg[j] <= BusW_MULT;	
					 else if(DataWen_MEM[j]) DataReg[j] <= BusW_MEM;	
						end
				 end
	endgenerate
	
	//register's reading
	assign BusA = DataReg[RS1];
	assign BusB = DataReg[RS2];
	
endmodule