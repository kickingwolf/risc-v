module ex(
input clk,//global signal
input rstn,

input	instruction_vld,//pipeline data
input [31:0]instruction,
input [31:0] PC,
input [31:0] exePC,
output [2:0]funct3,

output EXE_ready,
output EXE_flush,
output [31:0]EXE_real_PC,

output [31:0] MEM_address,//memory addr
output LOAD_vld,
output STORE_vld,
output [31:0]STORE_fifo_data,
output [4:0]LOAD_fifo_rd,
input  MEM_flush,//for MEM wrong

input LOAD_reg_wr,//register wr
input [4:0]LOAD_reg_rd,//register index
input [31:0]LOAD_reg_data,//register data

output CSR_wr,
output [11:0]CSR_index,
output [31:0]CSR_OPRA,
output [31:0]CSR_OPRI,
input [31:0] CSR_result,

output MRET,
output BREAK,
output ECALL,

output I_Illage
);
wire [4:0] rs1_index,rs2_index,rd_index;
wire [31:0]rs1_data,rs2_data;
wire subright;

wire conflict,rd_long_mark,rd_mark,rs1_mark,rs2_mark;

wire [31:0]ALU_OPRA,ALU_OPRB;
wire [4:0] ALU_shamt; 

wire [31:0]MUL_OPRA,MUL_OPRB;

wire [31:0]DIV_OPRA,DIV_OPRB;

wire [31:0]BTYPE_OPRA,BTYPE_OPRB;

wire [31:0]JALR_OPRA,JALR_OPRI,JAL_OPR;

wire [4:0] BIT_OPRB,BIT_OPRC;
wire [31:0]BIT_OPRA,BIT_OPRD;

wire [31:0]UTYPE_OPR;

wire [31:0]LOADSTORE_OPA,LOAD_OPB,STORE_OPB;

wire [31:0]BIT_result,DIV_result;

wire MULT_reg_wr;
wire [4:0] MULT_reg_rd;
wire [4:0] EXE_reg_rd;
wire EXE_reg_wr;
wire [31:0]MULT_reg_data;
wire [31:0]EXE_reg_data;


wire ALU_vld,MUL_vld,DIV_vld,BIT_vld,BTYPE_vld,JAL_vld,JALR_vld,LUI_vld,AUIPC_vld,CSR_vld;
wire JTYPE_FLUSH,BTYPE_FLUSH;
wire [31:0] JTYPE_REAL_ADDR,BTYPE_REAL_ADDR;
wire [31:0] BTYPE_offset;
assign EXE_flush  = JTYPE_FLUSH | BTYPE_FLUSH;
assign EXE_real_PC= ({32{JTYPE_FLUSH}} & JTYPE_REAL_ADDR) | ({32{BTYPE_FLUSH}} & BTYPE_REAL_ADDR);
assign CSR_wr	  = CSR_vld;
assign EXE_ready  = !conflict;
assign LOAD_fifo_rd= ({5{LOAD_vld}} & rd_index); 
assign STORE_fifo_data =({32{STORE_vld}} & rs2_data);

//************************************************************************************************************
ex_module u_ex_module
(
.instruction(instruction),
.instruction_vld(instruction_vld),

.rs1_index(rs1_index),
.rs1_data(rs1_data),
.rs2_index(rs2_index),
.rs2_data(rs2_data),
.rd_index(rd_index),

.funct3(funct3),
.subright(subright),

.conflict(conflict),
.rd_long_mark(rd_long_mark),
.rd_mark(rd_mark),
.rs1_mark(rs1_mark),
.rs2_mark(rs2_mark),

.ALU_OPRA(ALU_OPRA),
.ALU_OPRB(ALU_OPRB),
.ALU_shamt(ALU_shamt),

.MUL_OPRA(MUL_OPRA),
.MUL_OPRB(MUL_OPRB),

.DIV_OPRA(DIV_OPRA),
.DIV_OPRB(DIV_OPRB),

.BTYPE_OPRA(BTYPE_OPRA),
.BTYPE_OPRB(BTYPE_OPRB),
.BTYPE_offset(BTYPE_offset),

.JAL_OPR(JAL_OPR),
.JALR_OPRA(JALR_OPRA),
.JALR_OPRI(JALR_OPRI),

.BIT_OPRA(BIT_OPRA),
.BIT_ORPB(BIT_OPRB),
.BIT_OPRC(BIT_OPRC),
.BIT_OPRD(BIT_OPRD),
.UTYPE_OPR(UTYPE_OPR),

.LOADSTORE_OPA(LOADSTORE_OPA),
.LOAD_OPB(LOAD_OPB),
.STORE_OPB(STORE_OPB),

.CSR_index(CSR_index),
.CSR_OPRA(CSR_OPRA),
.CSR_OPRI(CSR_OPRI),

.ALU_vld(ALU_vld),
.MUL_vld(MUL_vld),
.DIV_vld(DIV_vld),
.BIT_vld(BIT_vld),
.BTYPE_vld(BTYPE_vld),
.JAL_vld(JAL_vld),
.JALR_vld(JALR_vld),
.LUI_vld(LUI_vld),
.AUIPC_vld(AUIPC_vld),
.LOAD_vld(LOAD_vld),
.STORE_vld(STORE_vld),
.CSR_vld(CSR_vld),

.MRET_vld(MRET),
.BREAK_vld(BREAK),
.ECALL_vld(ECALL),

.I_Illage(I_Illage)
);
//*******************************************************************************************************************


relevant u_relevant
(
.clk(clk),
.rstn(rstn),
.instruction_vaild(instruction_vld),
.rs1_index(rs1_index),
.rs2_index(rs2_index),
.rd_index(rd_index),

.rd_long_mark(rd_long_mark),
.rd_mark(rd_mark),
.rs1_mark(rs1_mark),
.rs2_mark(rs2_mark),

.conflict(conflict),
.MEM_flush(MEM_flush),

.MULT_reg_wr(MULT_reg_wr),
.MULT_reg_rd(MULT_reg_rd),

.LOAD_reg_wr(LOAD_reg_wr),
.LOAD_reg_rd(LOAD_reg_rd)
);
//*******************************************************************************************************************



RegFile u_RegFile
(
.clk(clk),
.rstn(rstn),
.RS1(rs1_index),
.RS2(rs2_index),
.Rd_EXE(EXE_reg_rd),
.Rd_MEM(LOAD_reg_rd),
.Rd_MULT(MULT_reg_rd),
.Wen_EXE(EXE_reg_wr),
.Wen_MEM(LOAD_reg_wr),
.Wen_MULT(MULT_reg_wr),
.BusW_EXE(EXE_reg_data),//----------------------------------------------------------------------------这三个记得填
.BusW_MEM(LOAD_reg_data),
.BusW_MULT(MULT_reg_data),
.BusA(rs1_data),
.BusB(rs2_data)
);
//*******************************************************************************************************************
wire [31:0] ALU_result;

ALU u_ALU
(
.rs1_data(ALU_OPRA),
.rs2_data(ALU_OPRB),
.funct3(funct3),
.subright(subright),
.shamt(ALU_shamt),
.ALU_result(ALU_result)
);
//*******************************************************************************************************************
wire [31:0] UTYPE_result;

UTYPE u_UTYPE
(
.LUI_vld(LUI_vld),
.AUIPC_vld (AUIPC_vld),
.PC(PC),
.UTYPE_OPR(UTYPE_OPR),
.UTYPE_result(UTYPE_result)
);
//*******************************************************************************************************************
//dui
LOAD_STORE u_LOAD_STORE
(
.LOAD_vld(LOAD_vld),
.STORE_vld(STORE_vld),
.LOADSTORE_OPA(LOADSTORE_OPA),
.LOAD_OPB(LOAD_OPB),
.STORE_OPB(STORE_OPB),

.MEM_address(MEM_address)
);
//*******************************************************************************************************************

BTYPE_compare u_compare
(
.BTYPE_vld(BTYPE_vld),
.BTYPE_OPRA(BTYPE_OPRA),
.BTYPE_OPRB(BTYPE_OPRB),
.funct3(funct3),
.PC(PC),
.exePC(exePC),
.BTYPE_offset(BTYPE_offset),

.BTYPE_FLUSH(BTYPE_FLUSH),//--------------------------------------------同上
.BTYPE_REAL_ADDR(BTYPE_REAL_ADDR)//-------------------------------------同上
);
//*******************************************************************************************************************

wire [31:0] j_reg_data;

JTYPE_jump u_jump
(
.Jal_vld(JAL_vld),
.Jalr_vld(JALR_vld),
.exePC(exePC),
.JAL_OPR(JAL_OPR),
.JALR_OPRA(JALR_OPRA),
.JALR_OPRI(JALR_OPRI),
.j_reg_data(j_reg_data),
.JTYPE_FLUSH(JTYPE_FLUSH),//--------------------------------------------肯定是名字不一样，同上
.JTYPE_REAL_ADDR(JTYPE_REAL_ADDR)//----------------------------------------------------记得�
);
//*******************************************************************************************************************

wire [31:0] MUL_result;

MUL u_MUL
(
.MUL_OPRA(MUL_OPRA),
.MUL_OPRB(MUL_OPRB),
.MUL_funct3(funct3),
.MUL_result(MUL_result)
);
//*******************************************************************************************************************
BIT u_BIT
(
.BIT_rs1_data(BIT_OPRA),
.BIT_rd_data(BIT_OPRD),
.BIT_imm2_rs2(BIT_OPRB),
.BIT_imm3_rs2(BIT_OPRC),
.BIT_funct3(funct3),
.BIT_result(BIT_result)
);

//*******************************************************************************************************************


WB u_WB
(
.clk(clk),
.rstn(rstn),

.ALU_vld(ALU_vld),
.MUL_vld(MUL_vld),
.DIV_vld(DIV_vld),
.BIT_vld(BIT_vld),

.JAL_vld(JAL_vld),
.JALR_vld(JALR_vld),
.LUI_vld(LUI_vld),
.AUIPC_vld(AUIPC_vld),
.CSR_vld(CSR_vld),

.rd_index(rd_index),

.CSR_result(CSR_result),
.ALU_result(ALU_result),
.UTYPE_result(UTYPE_result),
.BIT_result(BIT_result),
.j_reg_data(j_reg_data),

.MUL_result(MUL_result),
.DIV_result(DIV_result),

.EXE_reg_wr(EXE_reg_wr),
.EXE_reg_data(EXE_reg_data),
.EXE_reg_rd(EXE_reg_rd),

.MULT_reg_wr(MULT_reg_wr),
.MULT_reg_data(MULT_reg_data),
.MULT_reg_rd(MULT_reg_rd)
);
//*******************************************************************************************************************

endmodule
