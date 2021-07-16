module UTYPE (
input LUI_vld,
input AUIPC_vld,
input [31:0]PC,
input [31:0]UTYPE_OPR,
output[31:0] UTYPE_result
);

assign UTYPE_result = ({32{LUI_vld}} & UTYPE_OPR)|
					  ({32{AUIPC_vld}} & (UTYPE_OPR+PC));

endmodule