module LOAD_STORE(
input LOAD_vld,
input STORE_vld,
input [31:0] LOADSTORE_OPA,
input [31:0] LOAD_OPB,
input [31:0] STORE_OPB,
output [31:0] MEM_address
);
assign MEM_address = ({32{LOAD_vld}} & (LOADSTORE_OPA + LOAD_OPB)) |
					 ({32{STORE_vld}} & (LOADSTORE_OPA + STORE_OPB));
endmodule
