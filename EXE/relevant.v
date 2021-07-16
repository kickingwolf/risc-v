module relevant(
	input	clk,
	input 	rstn,

	input	[4:0]	rs1_index,
	input	[4:0]	rs2_index,
	input	[4:0]	rd_index,
	
	input instruction_vaild,
	
	input  	rd_long_mark,
	input	rs1_mark,
	input 	rs2_mark,
	input	rd_mark,
	
	output conflict,
	input  MEM_flush,
	
	input  MULT_reg_wr,
	input  LOAD_reg_wr,
	
	input [4:0] MULT_reg_rd,
	input [4:0] LOAD_reg_rd  
);
	
	
	reg [4:0] f0_rd;
	reg f0_vld;
	
	reg [4:0] f1_rd;
	reg f1_vld;

	reg [4:0] f2_rd;
	reg f2_vld;

	reg [4:0] f3_rd;
	reg f3_vld;
	

   wire remove0 = (MULT_reg_wr&(f0_rd==MULT_reg_rd)) | ( LOAD_reg_wr&(f0_rd==LOAD_reg_rd ));
	wire remove1 = (MULT_reg_wr&(f1_rd==MULT_reg_rd)) | ( LOAD_reg_wr&(f1_rd==LOAD_reg_rd ));
	wire remove2 = (MULT_reg_wr&(f2_rd==MULT_reg_rd)) | ( LOAD_reg_wr&(f2_rd==LOAD_reg_rd ));
	wire remove3 = (MULT_reg_wr&(f3_rd==MULT_reg_rd)) | ( LOAD_reg_wr&(f3_rd==LOAD_reg_rd ));
	wire ack0,ack1,ack2,ack3,conflict_rd,conflict_rs1,conflict_rs2;

always@(posedge clk or negedge rstn)
    if(~rstn) f0_vld <= 1'b0;
    else if(ack0 & rd_long_mark) f0_vld<=1'b1;
	else if(remove0) f0_vld <= 1'b0;			//预留给清�

always@(posedge clk or negedge rstn)
    if(~rstn) f1_vld <= 1'b0;
    else if(ack1 & rd_long_mark) f1_vld<=1'b1;
	else if(remove1) f1_vld <= 1'b0;			//预留给清�

always@(posedge clk or negedge rstn)
    if(~rstn) f2_vld <= 1'b0;
    else if(ack2 & rd_long_mark) f2_vld<=1'b1;
	else if(remove2) f2_vld <= 1'b0;			//预留给清�

always@(posedge clk or negedge rstn)
    if(~rstn) f3_vld <= 1'b0;
    else if(ack3 & rd_long_mark) f3_vld<=1'b1; 
	else if(remove3) f3_vld <= 1'b0;			//预留给清�
	
always@(posedge clk or negedge rstn)
   if(~rstn) begin f0_rd <= 5'd0;end
   else if(ack0 & rd_long_mark) begin f0_rd <= rd_index;end

always@(posedge clk or negedge rstn)
   if(~rstn) begin f1_rd <= 5'd0;end
   else if(ack1 & rd_long_mark) begin f1_rd <= rd_index;end

always@(posedge clk or negedge rstn)
   if(~rstn) begin f2_rd <= 5'd0;end
   else if(ack2 & rd_long_mark) begin f2_rd <= rd_index;end
   
always@(posedge clk or negedge rstn)
  if(~rstn) begin f3_rd <= 5'd0;end
  else if(ack3 & rd_long_mark) begin f3_rd <= rd_index;end
	
wire req0 = instruction_vaild & ~f0_vld & ~conflict& ~MEM_flush;
wire req1 = instruction_vaild & ~f1_vld & ~conflict& ~MEM_flush;
wire req2 = instruction_vaild & ~f2_vld & ~conflict& ~MEM_flush;
wire req3 = instruction_vaild & ~f3_vld & ~conflict& ~MEM_flush;

assign conflict_rd = (((rd_index == f0_rd) & f0_vld)| 
                      ((rd_index == f1_rd) & f1_vld)|
				      ((rd_index == f2_rd) & f2_vld)|
				      ((rd_index == f3_rd) & f3_vld)) & rd_mark;//WAW

assign conflict_rs1 = (((rs1_index == f0_rd) & f0_vld)| 
                       ((rs1_index == f1_rd) & f1_vld)|
				       ((rs1_index== f2_rd) & f2_vld)|
				       ((rs1_index == f3_rd) & f3_vld)) & rs1_mark;	//RAW			   

assign conflict_rs2 = (((rs2_index == f0_rd) & f0_vld)| 
                       ((rs2_index == f1_rd) & f1_vld)|
				       ((rs2_index == f2_rd) & f2_vld)|
				       ((rs2_index == f3_rd) & f3_vld)) & rs2_mark;//RAW

assign conflict = conflict_rd | conflict_rs1 | conflict_rs2 | (f0_vld & f1_vld & f2_vld & f3_vld) ;


arbiter4 uarbiter(.clk(clk),
                 .rst(rstn),
                .req({req3,req2,req1,req0}),
                .result({ack3,ack2,ack1,ack0}));
endmodule
