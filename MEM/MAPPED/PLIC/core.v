module plic_core
(
input rst_n,
input clk,
input  [14:0]src,
input  [14:0]el,
input  [14:0]ie,
input  [44:0] ipriority,
input  [2:0] threshold,

output ireq,
output [3:0] id,
input claim,
input complete
);
wire [14:0]claim_line;
wire [14:0]complete_line;
wire [14:0]ip;
reg  [3:0]id_claimed;
wire [59:0]id_line;
wire [44:0]pr_line;

genvar s;
generate
	for(s=0;s<15;s=s+1)
	begin:loop_gateway
		gateway gateway_inst(
		.rst_n		(rst_n),
		.clk		(clk),
		.src		(src[s]),
		.edge_lvl	(el[s]),
		.claim		(claim_line[s]),
		.complete	(complete_line[s]),
		.ip			(ip[s])
		);
	end
endgenerate

genvar h;
generate
	for(h=0;h<15;h=h+1)
		begin:loop_claims_source_line
			assign claim_line [h]=(id==h+1)?claim:1'b0;
			assign complete_line[h]=(id_claimed==h+1)?complete:1'b0;
		end
endgenerate

always@(posedge clk or negedge rst_n)
	if(!rst_n) id_claimed<=3'b0;
	else if (claim) id_claimed<=id;

genvar a;
generate
	for(a=0;a<15;a=a+1)
	begin:gen_cell_source_line
		plic_cell#(.ID(a+1)) cell_inst(
		.rst_ni(rst_n),
		.clk_i(clk),
		.ip_i(ip[a]),
		.ie_i(ie[a]),
		.priority_i(ipriority[(a*3)+2:a*3]),
		.id_o(id_line[(a*4)+3:a*4]),
		.priority_o(pr_line[(a*3)+2:a*3])
		);
	end
endgenerate

target target_inst(
.rst_n		(rst_n),
.clk			(clk),
.id_i			(id_line),
.priotity_i	(pr_line),
.threshold	(threshold),
.id_o			(id),
.ireq_o		(ireq)
);
endmodule
