module WB
(
input clk,
input rstn,

input ALU_vld,
input BIT_vld,
input JAL_vld,
input JALR_vld,
input LUI_vld,
input AUIPC_vld,

input [31:0]CSR_result,
input CSR_vld,

input MUL_vld,
input DIV_vld,


input [31:0]ALU_result,
input [31:0]UTYPE_result,
input [31:0]BIT_result,
input [31:0]j_reg_data,

input [31:0]MUL_result,
input [31:0]DIV_result,
input [4:0] rd_index,

output EXE_reg_wr,
output [31:0]EXE_reg_data,
output [4:0] EXE_reg_rd,

output reg MULT_reg_wr,
output [31:0]MULT_reg_data,
output reg[4:0]MULT_reg_rd
);

assign  EXE_reg_wr= ALU_vld | BIT_vld | JAL_vld | JALR_vld | LUI_vld | AUIPC_vld | CSR_vld;
assign  EXE_reg_rd=rd_index;
assign  EXE_reg_data=	({32{ALU_vld}} & ALU_result)|
						({32{BIT_vld}} & BIT_result)|
						({32{JAL_vld|JALR_vld}} & j_reg_data)|
						({32{LUI_vld|AUIPC_vld}}& UTYPE_result)|
						({32{CSR_vld}} & CSR_result);

reg [4:0]MULT_rd_buf;
reg MULT_reg_wr_buf;

always@(posedge clk or negedge rstn) begin
if(~rstn) MULT_reg_wr_buf <= 1'b0;
else MULT_reg_wr_buf <= MUL_vld;
end
always@(posedge clk or negedge rstn) begin
if(~rstn) MULT_reg_wr <= 1'b0;
else MULT_reg_wr <= MULT_reg_wr_buf;
end

always@(posedge clk or negedge rstn) begin
if(~rstn) MULT_rd_buf <= 4'b0;
else MULT_rd_buf <= rd_index;
end
always@(posedge clk or negedge rstn) begin
if(~rstn) MULT_reg_rd <= 4'b0;
else MULT_reg_rd <= MULT_rd_buf;
end
assign MULT_reg_data=MUL_result;
endmodule