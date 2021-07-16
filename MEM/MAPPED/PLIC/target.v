module target
(
input rst_n,
input clk,
input [59:0]id_i,
input [44:0]priotity_i,
input [2:0]threshold,
output reg ireq_o,
output reg[3:0]id_o
);

wire [3:0] id;
wire [2:0] pr;

plic_priority_index uut
(.priorityi(priotity_i),
.idx(id_i),
.priority_o(pr),
.idx_o(id)
);

always@(posedge clk or negedge rst_n)
	if (!rst_n) ireq_o<=1'b0;
	else if (pr > threshold) ireq_o<=1'b1;
	else 					 ireq_o<=1'b0;

always@(posedge  clk)
	id_o<=id;

endmodule