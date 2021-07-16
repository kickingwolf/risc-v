`timescale 1ns / 1ps
module MUL( 
input [31:0]MUL_OPRA,
input [31:0]MUL_OPRB,
input [2:0]MUL_funct3,
output [31:0]MUL_result
);

wire signed [31:0] rs1s,rs2s;
wire [63:0]#15result_u = MUL_OPRA * MUL_OPRB;
wire [31:0]result_uh = (MUL_funct3[0]) ? result_u[63:32] : result_u[31:0];

assign rs1s = MUL_OPRA;
assign rs2s = MUL_OPRB;
wire [63:0]#15result_s = rs1s * rs2s;
wire [31:0]result_sh = (MUL_funct3[0]) ? result_s[63:32] : result_s[31:0];

assign MUL_result = (MUL_funct3[1]) ? result_uh : result_sh;

endmodule
