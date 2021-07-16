`include "../parameter/CSR_OP.h"
module csr_register(
clk,RSTN,
I_A_M,I_A_F,I_I,BP,L_A_M,L_A_F,S_A_M,S_A_F,Ecall,MSIP,MTIP,MEIP,
hand,eventin,
value,EXE_ready,
IF_EXE_IN,MEM_addr,
IF_EXE_PC,BTYPE_real_PC,
mret,
WR,data_out,data_in,
PC_next,flush,reload_pc);

input clk;
input RSTN;
input I_A_M;			
input I_A_F;		
input I_I;			
input BP;			
input L_A_M;			
input L_A_F;			
input S_A_M;			
input S_A_F;			
input Ecall; 			
input MSIP;				
input MTIP;			
input MEIP;				

input hand;
input [31:0]eventin;

input value;
input EXE_ready;

input [31:0]IF_EXE_IN;
input [31:0]MEM_addr;	//options for wrong instruction

input [31:0]IF_EXE_PC;
input [31:0]BTYPE_real_PC;

input mret;

input WR;
input [31:0]data_in;	
output reg[31:0]data_out;

output [31:0]PC_next;
output flush;
output reload_pc;

wire [31:0] misa,mvendorid,marchid,mimpid,mhartid;	//which are supported to be configuration information,they should be hardwire
assign misa=      `misa1;						//hardwire
assign mvendorid= `mvendorid1;					//hardwire
assign marchid=	`marchid1;					//hardwire
assign mimpid=		`mimpid1;					//hardwire
assign mhartid=	`mhartid1;	

reg [31:3]HPM;											//mcountinhibit
reg IR,CY;
wire [31:0]mcountinhibit;
assign mcountinhibit[31:3]=HPM;
assign mcountinhibit[2]=IR;
assign mcountinhibit[1]=1'b0;
assign mcountinhibit[0]=CY;

reg [31:0]mhpmevent[3:31];							//event 
reg [63:0]mhpmcounter[3:31];						//event counter

reg [63:0]mcycle,minstret;							//performance counter 

reg  [31:0]mtval,mepc,msratch;						//parts of CSRs without hardwire bits

wire [31:0]mip,mie,status,mcause,mtvec;
reg INTERRUPT;											//mcause
reg [30:0]CODE;
assign mcause[31]	=INTERRUPT;
assign mcause[30:0]	=CODE;

reg[29:0]BASE;											//mtvec
reg[1:0]MODE;
assign mtvec[31:2]=BASE;
assign mtvec[1:0]=MODE;

assign mip[31:16]	=16'b0;							
assign mip[15:12]	=4'b0;								
assign mip[11]		=MEIP;								
assign mip[10]		=1'b0;								
assign mip[9]		=1'b0;								
assign mip[8]		=1'b0;								
assign mip[7]		=MTIP;							
assign mip[6]		=1'b0;								
assign mip[5]		=1'b0;								
assign mip[4]		=1'b0;								
assign mip[3]		=MSIP;								
assign mip[2]		=1'b0;								
assign mip[1]		=1'b0;								
assign mip[0]		=1'b0;								

reg MEIE,MTIE,MSIE;
assign mie[31:16]	=16'b0;
assign mie[15:12]	=4'b0;
assign mie[11]		=MEIE;
assign mie[10]		=1'b0;
assign mie[9]		=1'b0;
assign mie[8]		=1'b0;
assign mie[7]		=MTIE;
assign mie[6]		=1'b0;
assign mie[5]		=1'b0;
assign mie[4]		=1'b0;
assign mie[3]		=MSIE;
assign mie[2]		=1'b0;
assign mie[1]		=1'b0;
assign mie[0]		=1'b0;

reg MPIE,MIE_in;											//status
assign status[31]	=1'b0;
assign status[30:23]=8'b0;
assign status[22]	=1'b0;
assign status[21]	=1'b0;
assign status[20]	=1'b0;
assign status[19]	=1'b0;
assign status[18]	=1'b0;
assign status[17]	=1'b0;
assign status[16:15]=2'b0;
assign status[14:13]=2'b0;
assign status[12:11]=2'b11;
assign status[10:9]	=1'b0;
assign status[8]	=1'b0;
assign status[7]	=MPIE;
assign status[6]	=1'b0;
assign status[5]	=1'b0;
assign status[4]	=1'b0;
assign status[3]	=MIE_in;
assign status[2]	=1'b0;
assign status[1]	=1'b0;
assign status[0]	=1'b0;


wire[30:0] exception_code_in={{31'b0},{I_A_F}}
						|{{30'b0},{I_I},{1'b0}}
						|{{30'b0},{BP},{BP}}
						|{{29'b0},{L_A_M},{2'b0}}
						|{{29'b0},{L_A_F},{1'b0},{L_A_F}}
						|{{29'b0},{S_A_M},{S_A_M},{1'b0}}
						|{{29'b0},{S_A_F},{S_A_F},{S_A_F}}
						|{{28'b0},{Ecall},{1'b0},{Ecall},{Ecall}};
						
wire interrupt_claim=((MEIP&MEIE)|(MTIP&MTIE)|(MSIP&MSIE))&MIE_in;	
wire exception_claim=(I_A_M|I_A_F)|((I_I|BP|L_A_M|L_A_F|S_A_M|S_A_F|Ecall)&value);

wire [30:0]interrput_code_in= MEIP?31'd11:MTIP?31'd7:31'd3;
wire  interrupt_in=exception_claim?1'd0:1'd1;

	
wire flush_EXE=I_I|BP|L_A_M|L_A_F|S_A_M|S_A_F|Ecall;
wire flush_in =interrupt_claim;

wire exception_mtval_en =L_A_F|L_A_M|S_A_F|S_A_M;
wire trap_WR=exception_claim|interrupt_claim;

reg [31:0]EXE_MEM_PC;
reg [31:0]EXE_MEM_IN;
reg last_value;
reg [31:0]BTYPE_PC_dly1,BTYPE_PC_dly2;
//reg flush_EXE_dly;
reg flush_in_dly1/*,flush_in_dly2*/;
//reg mret_dly;
always@(posedge clk  or negedge RSTN)
begin
	if(!RSTN)
	begin
		EXE_MEM_PC<=32'b0;
		EXE_MEM_IN<=32'b0;
		last_value<=1'b0;
		BTYPE_PC_dly1<=32'b0;
		BTYPE_PC_dly2<=32'b0;
	//	flush_EXE_dly<=1'b0;
		flush_in_dly1<=1'b0;
	//	flush_in_dly2<=1'b0;
	//	mret_dly<=1'b0;
	end
	else if(EXE_ready)
		begin
		#0 EXE_MEM_PC<=IF_EXE_PC;
		#0 EXE_MEM_IN<=IF_EXE_IN;
		#0 last_value<=value;
		#0 BTYPE_PC_dly1<=BTYPE_real_PC;
		#0 BTYPE_PC_dly2<=BTYPE_PC_dly1;
		//#0 flush_EXE_dly<=flush_EXE;
		#0 flush_in_dly1<=flush_in;
	//#0 flush_in_dly2<=flush_in_dly1;
	//	#0 mret_dly<=mret;
		end
end
/*wire flush	  =flush_in | flush_in_dly1 |(flush_in_dly2 & MODE==2'b01) | flush_EXE | flush_EXE_dly| mret | mret_dly;*/
wire flush	  =flush_in |(flush_in_dly1 & MODE==2'b01) | flush_EXE | mret;
assign reload_pc= exception_claim |( interrupt_claim & MODE==1'b00) | (flush_in_dly1 & MODE==1'b01) | mret;
wire [2:0] CSR_func=IF_EXE_IN[14:12];
wire [11:0]addr  =IF_EXE_IN[31:20];
wire [4:0] data_imm=IF_EXE_IN[19:15];
wire [31:0]data_RI;										//choose data or set bits or clear bits from register or immediate
assign  data_RI=CSR_func[2]?{27'b0,data_imm}:data_in;	
reg [31:0]data_wr;										//data for writing CSRRW or CSRRC or CSRRS 
always@*
begin
	casez(CSR_func[1:0])
		`CSR_WRITE: #0data_wr= data_RI;
		`CSR_SET  : #0data_wr= data_RI |data_out;
		`CSR_CLEAN: #0data_wr=~data_RI &data_out;
		`CSR_NOP  : #0data_wr= data_out;
	endcase
end
always @(*)												//register map
begin
	casez(addr[11:8])
	4'h3:casez(addr[7:0])
			8'h01: data_out=misa;
			8'h00: data_out=status;
			8'h04: data_out=mie;
			8'h44: data_out=mip;
			8'h43: data_out=mtval;
			8'h41: data_out=mepc;
			8'h42: data_out=mcause;
			8'h05: data_out=mtvec;
			8'h40: data_out=msratch;
			
			8'h20: data_out=mcountinhibit;
			8'h23: data_out=mhpmevent[3];
			8'h24: data_out=mhpmevent[4];
			8'h25: data_out=mhpmevent[5];
			8'h26: data_out=mhpmevent[6];
			8'h27: data_out=mhpmevent[7];
			8'h28: data_out=mhpmevent[8];
			8'h29: data_out=mhpmevent[9];
			8'h2a: data_out=mhpmevent[10];
			8'h2b: data_out=mhpmevent[11];
			8'h2c: data_out=mhpmevent[12];
			8'h2d: data_out=mhpmevent[13];
			8'h2e: data_out=mhpmevent[14];
			8'h2f: data_out=mhpmevent[15];
	
			8'h30: data_out=mhpmevent[16];	
			8'h31: data_out=mhpmevent[17];
			8'h32: data_out=mhpmevent[18]; 
			8'h33: data_out=mhpmevent[19];
			8'h34: data_out=mhpmevent[20];
			8'h35: data_out=mhpmevent[21];
			8'h36: data_out=mhpmevent[22];
			8'h37: data_out=mhpmevent[23];
			8'h38: data_out=mhpmevent[24];
			8'h39: data_out=mhpmevent[25];
			8'h3a: data_out=mhpmevent[26];
			8'h3b: data_out=mhpmevent[27];
			8'h3c: data_out=mhpmevent[28];
			8'h3d: data_out=mhpmevent[29];
			8'h3e: data_out=mhpmevent[30];
			8'h3f: data_out=mhpmevent[31];
			default:
			data_out=32'b0;
	
			endcase
	4'hb:casez(addr[7:0])
			8'h00: data_out=mcycle[31:0];
			8'h02: data_out=minstret[31:0];
			8'h03: data_out=mhpmcounter[3][31:0];
			8'h04: data_out=mhpmcounter[4][31:0];
			8'h05: data_out=mhpmcounter[5][31:0];
			8'h06: data_out=mhpmcounter[6][31:0];
			8'h07: data_out=mhpmcounter[7][31:0];
			8'h08: data_out=mhpmcounter[8][31:0];
			8'h09: data_out=mhpmcounter[9][31:0];
			8'h0a: data_out=mhpmcounter[10][31:0];
			8'h0b: data_out=mhpmcounter[11][31:0];
			8'h0c: data_out=mhpmcounter[12][31:0];
			8'h0d: data_out=mhpmcounter[13][31:0];
			8'h0e: data_out=mhpmcounter[14][31:0];
			8'h0f: data_out=mhpmcounter[15][31:0];
	
			8'h10: data_out=mhpmcounter[16][31:0];
			8'h11: data_out=mhpmcounter[17][31:0];
			8'h12: data_out=mhpmcounter[18][31:0];
			8'h13: data_out=mhpmcounter[19][31:0];
			8'h14: data_out=mhpmcounter[20][31:0];
			8'h15: data_out=mhpmcounter[21][31:0];
			8'h16: data_out=mhpmcounter[22][31:0];	
			8'h17: data_out=mhpmcounter[23][31:0];
			8'h18: data_out=mhpmcounter[24][31:0];
			8'h19: data_out=mhpmcounter[25][31:0];
			8'h1a: data_out=mhpmcounter[26][31:0];
			8'h1b: data_out=mhpmcounter[27][31:0];
			8'h1c: data_out=mhpmcounter[28][31:0];
			8'h1d: data_out=mhpmcounter[29][31:0];
			8'h1e: data_out=mhpmcounter[30][31:0];
			8'h1f: data_out=mhpmcounter[31][31:0];
			8'h80: data_out=mcycle[63:32]; 
			8'h82: data_out=minstret[63:32];
			8'h83: data_out=mhpmcounter[3][63:32];
			8'h84: data_out=mhpmcounter[4][63:32];
			8'h85: data_out=mhpmcounter[5][63:32];
			8'h86: data_out=mhpmcounter[6][63:32];
			8'h87: data_out=mhpmcounter[7][63:32]; 
			8'h88: data_out=mhpmcounter[8][63:32];
			8'h89: data_out=mhpmcounter[9][63:32];
			8'h8a: data_out=mhpmcounter[10][63:32];
			8'h8b: data_out=mhpmcounter[11][63:32];
			8'h8c: data_out=mhpmcounter[12][63:32];
			8'h8d: data_out=mhpmcounter[13][63:32];
			8'h8e: data_out=mhpmcounter[14][63:32];
			8'h8f: data_out=mhpmcounter[15][63:32];
			
			8'h90: data_out=mhpmcounter[16][63:32];
			8'h91: data_out=mhpmcounter[17][63:32];
			8'h92: data_out=mhpmcounter[18][63:32];
			8'h93: data_out=mhpmcounter[19][63:32];
			8'h94: data_out=mhpmcounter[20][63:32];
			8'h95: data_out=mhpmcounter[21][63:32];
			8'h96: data_out=mhpmcounter[22][63:32];
			8'h97: data_out=mhpmcounter[23][63:32];
			8'h98: data_out=mhpmcounter[24][63:32];
			8'h99: data_out=mhpmcounter[25][63:32];
			8'h9a: data_out=mhpmcounter[26][63:32];
			8'h9b: data_out=mhpmcounter[27][63:32];
			8'h9c: data_out=mhpmcounter[28][63:32];
			8'h9d: data_out=mhpmcounter[29][63:32];
			8'h9e: data_out=mhpmcounter[30][63:32];
			8'h9f: data_out=mhpmcounter[31][63:32];
			default:
			data_out=32'b0;
			endcase
	4'hf:casez(addr[7:0])
			8'h11: data_out=mvendorid;
			8'h12: data_out=marchid;
			8'h13: data_out=mimpid;
			8'h14: data_out=mhartid;
			default:
			data_out=32'b0;
			endcase
	default:
	data_out=32'b0;
	endcase
end

always@(posedge clk or negedge RSTN)
begin
	if(!RSTN)
		begin
		HPM<=29'b0;
		IR<=1'b0;
		CY<=1'b0;
		end
	else
		begin
			if(WR && addr==12'h320)
				begin
				HPM<=data_wr[31:3];
				IR <=data_wr[2];
				CY <=data_wr[0];
				end
		end
end

genvar i;
generate for (i=3;i<32;i=i+1) begin: r_loop			//event set and event counter, when instruction equals to data in event and counter receives the instruction hand over,the event counter will add 1

		always@(posedge clk or negedge RSTN)				
		begin
			if(!RSTN)
				begin
				mhpmevent[i]  	<=32'b0;			//29 events reset
				mhpmcounter[i]	<=64'b0;			//29 eventcounters reset
				end
			else
				begin
				if(addr==12'h320+i && WR)		//29 events CSRRW or CSRRC or  CSRRS
				mhpmevent[i]	<=data_wr;				
				if((mhpmevent[i]!=32'b0)&&(mhpmevent[i] == eventin) && HPM[i])	//29 eventcounters add condition
				mhpmcounter[i]	<=mhpmcounter[i]+1'b1;
				end			
		end
								end
endgenerate

always@(posedge clk or negedge RSTN)
begin
	if(!RSTN)
		begin
			mcycle<=64'b0;							//clk cycle couner reset
			minstret<=64'b0;						//the counter which logs number of  instruction executed.it resets to 0
		end
	else
		begin
			mcycle<=mcycle+1'b1;
			if(hand)
			minstret<=minstret+1'b1;
		end
end

always@(posedge clk or negedge RSTN)								//mtval 
begin
	if(!RSTN)
			mtval<=32'b0;									//mtval reset
	else
		begin
		if(WR && addr==12'h343)						//mtval RC RS RW
			mtval<=data_wr;
		if(exception_claim)								//when the trap happens,it will record the error instruction or error memory address 
			casez(exception_mtval_en)
			1'b0:begin
					if(({{EXE_MEM_IN[6:4]},{EXE_MEM_IN[2:0]}}==6'b110111)  || ((EXE_MEM_IN[6:0]==7'b1100011) & !EXE_MEM_IN[31]))
					mtval <=EXE_MEM_IN;
					else
					mtval <=IF_EXE_IN;
				  end
			1'b1:	mtval <=MEM_addr;
			endcase	
		end
end

always@(posedge clk or negedge RSTN)			
begin
	if(!RSTN)
	msratch<=32'b0;								
	else if(WR && addr==12'h340)						
	msratch<=data_wr;
end

always@(posedge clk or negedge RSTN)
begin
	if(!RSTN)
		mepc<=32'b0;
	else
		begin
			if(WR && addr==12'h341)
				mepc<=data_wr;
			if(trap_WR)
				begin
				casez(interrupt_claim)
					1'b0:	if(({{EXE_MEM_IN[6:4]},{EXE_MEM_IN[2:0]}}==6'b110111) | ((EXE_MEM_IN[6:0]==7'b1100011) & !EXE_MEM_IN[31]))
								mepc <= EXE_MEM_PC;
							else
								mepc <= IF_EXE_PC;
					1'b1:   if((~(({{IF_EXE_IN[6:4]},{IF_EXE_IN[2:0]}}==6'b110111) | (IF_EXE_IN[6:0]==7'b1100011))) & value)
								mepc <= IF_EXE_PC+32'd4;
							else if(({{IF_EXE_IN[6:4]},{IF_EXE_IN[2:0]}}==6'b110111) | (IF_EXE_IN[6:0]==7'b1100011) & value)
								mepc <= BTYPE_real_PC;
							else if(last_value)
								mepc <= BTYPE_PC_dly1;
							else
								mepc <= BTYPE_PC_dly2;
				endcase
				end
		end
end



always@(posedge clk or negedge RSTN)					
begin
	if(!RSTN)											//MIE reset
		begin
		MEIE<=1'b1;
		MTIE<=1'b1;
		MSIE<=1'b1;
		end
	else
		begin
			if(WR && addr==12'h304)						//MIE RW or RS or RC
				begin
				MEIE<=data_wr[11];
				MTIE<=data_wr[7];
				MSIE<=data_wr[3];
				end
		end
end


always@(posedge clk or negedge RSTN)					
begin
	if(!RSTN)											//status reset
		begin
		MPIE<=1'b1;
		MIE_in <=1'b1;
		end
	else
		begin	
		if(WR && addr==12'h300)							//status RW or RS or RC
			begin
			MPIE<=data_wr[7];
			MIE_in <=data_wr[3];
			end
		if(trap_WR)										//MIE is global interrupt enable;when trap happens ,global interrupt enable will turn off
			begin
			MPIE<=MIE_in;
			MIE_in <=1'b0;
			end
		if(mret)
			begin
			MPIE<=1'b1;
			MIE_in <=MPIE;
			end
		end
end

always@(posedge clk  or negedge RSTN)
begin
	if(!RSTN)											//mcause reset
		begin
		INTERRUPT<=1'b0;
		CODE<=31'b0;
		end
	else
		begin
			if(WR && addr==12'h342)						//mcause RW RS RC
				begin
				INTERRUPT<=data_wr[31];
				CODE     <=data_wr[30:0];
				end
			if(trap_WR)									//
				begin
				INTERRUPT<=interrupt_in;
				CODE     <=exception_claim ?exception_code_in:interrput_code_in;
				end
		end
end

always@(posedge clk  or negedge RSTN)
begin
	if(!RSTN)
		begin
		BASE<=`BASE;
		MODE<=2'b01;
		end
	else
		begin
			if(WR && addr==12'h305)
				begin
				BASE<=data_wr[31:2];
				MODE<=data_wr[1:0];
				end
		end
end
reg[31:0]trap_PC_next;
always@*
begin
case(MODE)
`base_mode  : trap_PC_next=BASE;
`vector_mode: begin
		 if(INTERRUPT)
			trap_PC_next=BASE+(CODE<<2);
		 else
			trap_PC_next=BASE;
		 end
default:begin
			trap_PC_next=BASE;
		 end
endcase
end

assign PC_next=(mret)?mepc:trap_PC_next;
endmodule
