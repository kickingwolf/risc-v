module ex_module
(
input [31:0]instruction,
input instruction_vld,

output [4:0] rs1_index,
input  [31:0]rs1_data,
output [4:0] rs2_index,
input  [31:0]rs2_data,
output [4:0] rd_index,

output [2:0]funct3,
output subright,

input  conflict,
output rd_long_mark,
output rd_mark,
output rs1_mark,
output rs2_mark,

output [31:0]ALU_OPRA,
output [31:0]ALU_OPRB,
output [4:0]ALU_shamt,

output [31:0]BIT_OPRA,
output [4:0]BIT_ORPB,
output [4:0]BIT_OPRC,
output [31:0]BIT_OPRD,

output [31:0]MUL_OPRA,
output [31:0]MUL_OPRB,

output [31:0]DIV_OPRA,
output [31:0]DIV_OPRB,

output [31:0]BTYPE_OPRA,
output [31:0]BTYPE_OPRB,
output [31:0]BTYPE_offset,

output [31:0]JAL_OPR,
output [31:0]JALR_OPRA,
output [31:0]JALR_OPRI,

output [31:0]UTYPE_OPR,

output [31:0]LOADSTORE_OPA,
output [31:0]LOAD_OPB,
output [31:0]STORE_OPB,

output [11:0]CSR_index,
output [31:0]CSR_OPRA,
output [31:0]CSR_OPRI,

output ALU_vld,
output MUL_vld,
output DIV_vld,
output BIT_vld,
output BTYPE_vld,
output JAL_vld,
output JALR_vld,
output LUI_vld,
output AUIPC_vld,
output LOAD_vld,
output STORE_vld,
output CSR_vld,

output MRET_vld,
output BREAK_vld,
output ECALL_vld,

output I_Illage
);

assign funct3	=instruction[14:12];
wire [6:0]funct7	=instruction[31:25];
wire [11:0]funct12	=instruction[31:20];
//===============tanslate Op==================================
wire [6:0] Op=instruction[6:0];
wire RTYPE	= (Op==7'b0110011);
wire ITYPE	= (Op==7'b0010011);  
wire BTYPE	= (Op==7'b1100011);
wire LUI	= (Op==7'b0110111);
wire AUIPC	= (Op==7'b0010111);
wire LOAD	= (Op==7'b0000011);
wire STORE	= (Op==7'b0100011);
wire SYSTEM	= (Op==7'b1110011);
wire JAL	= (Op==7'b1101111);
wire JALR 	= (Op==7'b1100111);
assign I_Illage= !RTYPE & !ITYPE & !BTYPE & !LUI & !AUIPC & !LOAD & !STORE & !SYSTEM & !JAL & !JALR & !SYSTEM & !(instruction==32'b0);
//===============tanslate function==================================
wire RTYPE_BASE	=RTYPE &(funct7==7'b00000000 | funct7==7'b01000000);
wire RTYPE_MUL	 	=RTYPE &(funct7==7'b0000001)&(!funct3[2]);
wire RTYPE_DIV		=RTYPE &(funct7==7'b0000001)&( funct3[2]);
wire RTYPE_BIT		=RTYPE &(funct7[6]==1'b1);
wire RTYPE_BIT_rd =RTYPE_BIT & (funct3==3'b010);
wire ITYPE_unsign =ITYPE & (funct3==3'b011 | funct3==3'b100 | funct3==3'b110 | funct3==3'b111);
wire ITYPE_sign   =ITYPE & (funct3==3'b000 | funct3==3'b010);
wire SYSTEM_MRET	=SYSTEM&(funct12==12'b0011_0000_0010)&(~|funct3);
wire SYSTEM_ECALL	=SYSTEM&(funct12==12'b0000_0000_0000)&(~|funct3);
wire SYSTEM_BREAK	=SYSTEM&(funct12==12'b0000_0000_0001)&(~|funct3);
wire SYSTEM_CSR 	=SYSTEM &(|funct3);
//===============commute with relevant==================================
assign rd_long_mark	= instruction_vld &(LOAD | RTYPE_DIV | RTYPE_MUL);
assign rd_mark		   = instruction_vld &(RTYPE_BASE | ITYPE | LUI | AUIPC | JAL | JALR | LOAD | RTYPE_DIV | RTYPE_MUL | SYSTEM_CSR);
assign rs1_mark		= instruction_vld &(RTYPE_BASE | RTYPE_MUL | RTYPE_DIV | ITYPE | JALR | BTYPE | LOAD | STORE | SYSTEM_CSR);
assign rs2_mark		= instruction_vld &(RTYPE_BASE | RTYPE_MUL | RTYPE_DIV | BTYPE | STORE);
//=========================IMM generator=================================
wire [31:0] ITYPE_Imm	=({32{ITYPE_sign}}&{{20{instruction[31]}},{instruction[31:20]}})|
								({32{ITYPE_unsign}}&{20'b0,{instruction[31:20]}});
wire [31:0]	JAL_Imm		={{12{instruction[20]}},{instruction[19:12]},{instruction[20]},{instruction[30:21]},1'b0};
wire [31:0] BTYPE_Imm	={{20{instruction[12]}},{instruction[7]},{instruction[30:25]},{instruction[11:8]},1'b0};
wire [31:0] STORE_Imm	={{20{instruction[31]}},{instruction[31:25]},{instruction[11:7]}};
wire [31:0] LOAD_Imm		={{20{instruction[31]}},{instruction[31:20]}};
wire [31:0] UTYPE_Imm	={{instruction[31:12]},{12'b0}};
wire [31:0] CSR_Imm		={{27'b0},{instruction[19:15]}};
wire [4:0]  BIT_Imm2		=instruction[24:20];
wire [4:0]  BIT_Imm3		=instruction[29:25];
//=======================================================================
//===================commute with reg====================================
assign rs1_index =instruction[19:15];
assign rs2_index =RTYPE_BIT_rd?instruction[11:7]:instruction[24:20];
assign rd_index  =instruction[11:7];
//=======================================================================
//===================commute with alu====================================
assign ALU_vld   = instruction_vld & ~conflict &(ITYPE | RTYPE_BASE);
assign ALU_OPRA   =rs1_data;
assign ALU_OPRB   =({32{RTYPE_BASE}}&rs2_data)|
						 ({32{ITYPE}}&ITYPE_Imm);
assign ALU_shamt  = instruction[24:20];
assign subright	       =funct7[5]&RTYPE_BASE;
//========================================================================	
//===================commute with MUL=====================================
assign MUL_vld = instruction_vld & ~conflict & RTYPE_MUL;
assign MUL_OPRA = rs1_data;
assign MUL_OPRB = rs2_data;
//========================================================================	
//===================commute with div=====================================
assign DIV_vld = instruction_vld & ~conflict & RTYPE_DIV;
assign DIV_OPRA = rs1_data;
assign DIV_OPRB = rs2_data;
//======================================================================	
//===================commute with BIT===================================
assign BIT_vld = instruction_vld & ~conflict & RTYPE_BIT;
assign BIT_OPRA = rs1_data;
assign BIT_ORPB = ({5{funct7[5]}} & BIT_Imm2) |({5{~funct7[5]}} & rs2_data[4:0]);
assign BIT_OPRC = ({5{funct7[5]}} & BIT_Imm3) |({5{~funct7[5]}} & rs2_data[9:5]);
assign BIT_OPRD = rs2_data;
//======================================================================
//=====================commute with BTYPE===============================
assign BTYPE_vld = instruction_vld & ~conflict & BTYPE;
assign BTYPE_OPRA = rs1_data;
assign BTYPE_OPRB = rs2_data;
assign BTYPE_offset=BTYPE_Imm;
//======================================================================
//=====================commute with JAL===============================
assign JAL_vld	= instruction_vld & ~conflict & JAL;
assign JAL_OPR	= JAL_Imm;
//======================================================================
//=====================commute with JALR===============================
assign JALR_vld	= instruction_vld & ~conflict & JALR;
assign JALR_OPRA	= rs1_data;
assign JALR_OPRI	= ITYPE_Imm;
//======================================================================	
//===================commute with UTYPE=====================================
assign LUI_vld	= instruction_vld & ~conflict & LUI;
assign AUIPC_vld	= instruction_vld & ~conflict & AUIPC;
assign UTYPE_OPR 	= UTYPE_Imm;
//=======================================================================
//===================commute with LOAD/STORE==============================
assign LOAD_vld 		= instruction_vld & ~conflict & LOAD;
assign STORE_vld	 	= instruction_vld & ~conflict & STORE;
assign LOADSTORE_OPA 	= rs1_data;
assign LOAD_OPB			= LOAD_Imm;
assign STORE_OPB		   = STORE_Imm;
//======================================================================	
//===================commute with CSR=====================================
assign CSR_vld  = instruction_vld & ~conflict & SYSTEM_CSR;
assign CSR_index= instruction[31:20];
assign CSR_OPRA = rs1_data;
assign CSR_OPRI = CSR_Imm;
//======================================================================	
//===================commute with INC=====================================
assign MRET_vld =SYSTEM_MRET &instruction_vld & ~conflict;
assign ECALL_vld=SYSTEM_ECALL&instruction_vld & ~conflict;
assign BREAK_vld=SYSTEM_BREAK&instruction_vld & ~conflict;

endmodule
