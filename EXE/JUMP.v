module JTYPE_jump
(
input Jal_vld,
input Jalr_vld,
input [31:0]exePC,
input [31:0]JAL_OPR,
input [31:0]JALR_OPRA,
input [31:0]JALR_OPRI,

output [31:0]j_reg_data,
output JTYPE_FLUSH,
output [31:0]JTYPE_REAL_ADDR
);

wire [31:0]JALR_result 	  = JALR_OPRA+JALR_OPRI;
assign JTYPE_FLUSH    = Jal_vld | Jalr_vld;
assign JTYPE_REAL_ADDR = ({32{Jal_vld}} & (exePC+JAL_OPR))|
								({32{Jalr_vld}} & {JALR_result[31:1],{1'b0}});
assign j_reg_data	  = exePC+3'd4;

endmodule
