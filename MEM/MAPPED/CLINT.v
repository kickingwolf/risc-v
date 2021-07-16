module CLINT(
input clk,
input rst_n,
input wr_H_rd_L,
input load,
input [3:0]addr,
input [31:0]wdata,
output reg[31:0]rdata,
output reg time_interrupt,
output reg msip_reg)
;
reg [31:0]PRESCALER;
reg [63:0]TIME;
reg [1:0]IENABLE_reg;
reg [1:0]IPEMDING_reg;
reg [63:0]TIMECMP0;
reg [63:0]TIMECMP1;
reg prescale_wr;
reg count_enable;
reg enabled;
reg [31:0]prescale_cnt;
always@(posedge clk or negedge rst_n)
	if(!rst_n)
		rdata<=32'b0;
	else if(!wr_H_rd_L)
		case(addr)
		4'd0:		rdata<=PRESCALER;
		4'd1:    rdata<=TIME[31:0];
		4'd2: 	rdata<=TIME[63:32];
		4'd3:  	rdata<={{29'b0},{IENABLE_reg}};
		4'd4:		rdata<={{29'b0},{IPEMDING_reg}};
		4'd5: 	rdata<=TIMECMP0[31:0];
		4'd6: 	rdata<=TIMECMP0[63:32];
		4'd7: 	rdata<=TIMECMP1[31:0];
		4'd8:		rdata<=TIMECMP1[63:32];
		4'd9:     rdata<={{30'b0},{msip_reg}};
		default: rdata<=32'd0;
		endcase

always@(posedge clk or negedge rst_n)
	if(!rst_n)
		begin
			PRESCALER	 <=32'b0;
			TIME	 		 <=64'b0;
			IENABLE_reg	 <=2'b0;
			IPEMDING_reg <=2'b0;
			TIMECMP0		 <=64'b0;
			TIMECMP1		 <=64'b0;
			msip_reg		 <=1'b0;
			enabled<=1'b0;
		end
	else
		begin
			prescale_wr	<=1'b0;
			IPEMDING_reg[0]<=enabled & (TIMECMP0==TIME);
			IPEMDING_reg[1]<=enabled & (TIMECMP1==TIME);
			if(count_enable)TIME<=TIME+1'b1;
			if(wr_H_rd_L)
				case(addr)
					4'd0:		begin
									PRESCALER	<=wdata;
									enabled		<=1'b1;
									prescale_wr	<=1'b1;
								end
					4'd1:   		TIME[31:0]  <=wdata;
					4'd2: 		TIME[63:32] <=wdata;
					4'd3:  		IENABLE_reg <=wdata[1:0];
					4'd4:		;//read_only
					4'd5: 		TIMECMP0	<=wdata;
					4'd6: 		TIMECMP0 <=wdata;
					4'd7: 		TIMECMP1 <=wdata;
					4'd8:			TIMECMP1	<=wdata;
					4'd9:     	msip_reg  <=wdata[0];
				endcase
		end

always@(posedge clk or negedge rst_n)
	if(!rst_n) prescale_cnt<=32'b0;
	else if(prescale_wr || ~|prescale_cnt) prescale_cnt<=PRESCALER;
	else								   prescale_cnt<=prescale_cnt-1'b1;
	
always@(posedge clk or negedge rst_n)
	if		(!rst_n) 	count_enable <= 1'b0;
	else if(!enabled)	count_enable <= 1'b0;
	else 				count_enable<=~|prescale_cnt;



always@(posedge clk or negedge rst_n)
	if		(!rst_n)						time_interrupt<=1'b0;
	else if (|(IENABLE_reg & IPEMDING_reg))	time_interrupt<=1'b1;
	else									time_interrupt<=1'b0;
	
endmodule