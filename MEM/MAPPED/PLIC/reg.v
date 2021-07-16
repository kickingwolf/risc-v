module PLIC_reg(
input rst_n,
input clk,
input wr_H_rd_L,
input load,
input [31:0]wdata,
input [2:0] addr,
output reg [31:0]rdata,


output reg[14:0]el,
output reg[14:0]ie,
output [44:0]PW,
output reg [2:0]TH,
input [3:0]id,
output reg claim,
output reg complete
);

wire [63:0]CONFIGI;
assign CONFIGI={{15'b0},{1'b1},{16'd8},{16'd1},{16'd15}};

wire [31:0]EL;
assign EL={{17'b0},{el}};

wire [31:0]IE;
assign IE={{17'b0},{ie}};

wire [31:0]PRIORITY[1:0];
reg [2:0]P[0:14];
assign PRIORITY[0]={{{1'b0},{P[7]}},{{1'b0},{P[6]}},{{1'b0},{P[5]}},
{{1'b0},{P[4]}},{{1'b0},{P[3]}},{{1'b0},{P[2]}},{{1'b0},{P[1]}},{{1'b0},{P[0]}}};
assign PRIORITY[1]={{4'b0},{{1'b0},{P[14]}},{{1'b0},{P[13]}},
{{1'b0},{P[12]}},{{1'b0},{P[11]}},{{1'b0},{P[10]}},{{1'b0},{P[9]}},{{1'b0},{P[8]}}};
assign PW={{P[14]},{P[13]},{P[12]},{P[11]},{P[10]},{P[9]},{P[8]},{P[7]},{P[6]},{P[5]},{P[4]},{P[3]},{P[2]},{P[1]},{P[0]}};
wire [31:0]THRESHOLD;
assign THRESHOLD={{29'b0},{TH}};



always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		rdata<=32'b0;
	else if(!wr_H_rd_L)
	case(addr)
	3'b000: rdata<= CONFIGI[31:0];
	3'b001:	rdata<= CONFIGI[63:32];
	3'b010:	rdata<= EL;
	3'b011:	rdata<= IE;
	3'b100:	rdata<= PRIORITY[0];
	3'b101:	rdata<= PRIORITY[1];
	3'b110:	rdata<= THRESHOLD;
	3'b111:	rdata<=	id;
	default:rdata<=32'd0;
	endcase
end


always@(posedge clk or negedge rst_n)
	if(!rst_n)
		el<=15'b0;
	else if(wr_H_rd_L & addr==3'b010)
		el<=wdata[14:0];

	
always@(posedge clk or negedge rst_n)
	if(!rst_n)
		ie<=15'b0;
	else if(wr_H_rd_L & addr==3'b011)
		ie<=wdata[14:0];

always@(posedge clk or negedge rst_n)
	if(!rst_n)
		TH<=3'b0;
	else if(wr_H_rd_L & addr==3'b110)
		TH<=wdata[2:0];
		
always@(posedge clk or negedge rst_n)
	if(!rst_n)
		begin
			P[0]<=3'b0;
			P[1]<=3'b0;
			P[2]<=3'b0;
			P[3]<=3'b0;
			P[4]<=3'b0;
			P[5]<=3'b0;
			P[6]<=3'b0;
			P[7]<=3'b0;
			P[8]<=3'b0;
			P[9]<=3'b0;
			P[10]<=3'b0;
			P[11]<=3'b0;
			P[12]<=3'b0;
			P[13]<=3'b0;
			P[14]<=3'b0;
		end
	else if(wr_H_rd_L & addr==3'b100)
		begin
			P[0]<=wdata[2:0];
			P[1]<=wdata[6:4];
			P[2]<=wdata[10:8];
			P[3]<=wdata[14:12];
			P[4]<=wdata[18:16];
			P[5]<=wdata[22:20];
			P[6]<=wdata[26:24];
			P[7]<=wdata[30:28];
		end
	else if(wr_H_rd_L & addr==3'b101)
		begin
			P[8]<=wdata[2:0];
			P[9]<=wdata[6:4];
			P[10]<=wdata[10:8];
			P[11]<=wdata[14:12];
			P[12]<=wdata[18:16];
			P[13]<=wdata[22:20];
			P[14]<=wdata[26:24];
		end
		
always@(posedge clk or negedge rst_n)
	if(!rst_n) claim <= 1'b0;
	else 	   claim <= (addr==3'b111 && load);


always@(posedge clk or negedge rst_n)
	if(!rst_n) complete <= 1'b0;
	else 	   complete <= (addr==3'b111 && wr_H_rd_L);
	
endmodule 