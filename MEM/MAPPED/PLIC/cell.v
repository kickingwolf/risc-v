module plic_cell#(parameter ID=1)
(
input rst_ni,
input clk_i,
input ip_i,
input ie_i,
input [2:0] priority_i, //7个优先级

output reg [3:0] id_o,	//
output reg [2:0] priority_o
);

always@(posedge clk_i or negedge rst_ni)
	if		(!rst_ni)		priority_o<=0;
	else if (ip_i && ie_i)	priority_o<=priority_i;
	else					priority_o<=0;
	
always@(posedge clk_i or negedge rst_ni)
	if		(!rst_ni)	    id_o <= 0;
	else if	(ip_i && ie_i)  id_o <= ID;
	else					id_o <= 0;

endmodule