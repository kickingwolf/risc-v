module csr_register();

input Instruction_address_misaligned;			//exception request
input Instruction_access_fault;					//exception request
input Illegal_instruction;						//exception request
input Breakpoint;								//exception request
input Load_address_misaligned;					//exception request
input Load_access_fault;						//exception request
input Store_address_misaligned;					//exception request
input Store_access_fault;						//exception request
input Ecall; 									//exception request
input Soft_interrupt;							//interrupt request
input Timer_interrupt;							//interrupt request
input External_interrupt;						//interrupt request

input mret;										//MRET TRAP RETURN  we need IF stage to translate the MRET and to choose the next_PC from mepc

input data_reg;									//CSRRW register data input
input data_imm;									//CSRRW immediate data input
input addr;  									//CSRRW index addr
input WR;										//CSRRW Write enable
output data_out;								//CSRRW data out

output [31:0]PC_next;
assign PC_next=mert?mepc_out:trap_PC_next;
wire [31:0]mepc_out;
assign mepc_out=mepc;

input [31:0]IN,ID_EXE_IN,IF_ID_IN,MEM_addr;		//options for wrong instruction
input [31:0]PC,ID_EXE_PC,IF_ID_PC,EXE_MEM_PC;	//options for returning PC

							

reg trap_WR,mtval_WR;							//status,mepc,mtval,mcause register write enable during in trap
task exception_Write;
trap_WR		<=1'b1;
mtval_WR	<=1'b1;
endtask

task interrupt_Write;
trap_WR		<=1'b1;
mtval_WR	<=1'b0;
endtask

reg [30:0]code_in;								//interrupt or exception code
reg interrupt_in;								//interrupt or exception
reg pc_in_sel;									//choose the right options for return PC or wrong instruction
always@*
begin
	casez({	Instruction_address_misaligned,		//priority encoder to encode interrupt or exception and to encode interrupt or exception as well as trap enable
			Instruction_access_fault,
			Illegal_instruction,
			Breakpoint,
			Load_address_misaligned,
			Load_access_fault,
			Store_address_misaligned,
			Store_access_fault,
			Ecall
			MSIP
			MTIP
			MEIP;
			})
	12'b1???_????_????:	begin
					code_in=31'd0;
					interrupt_in=1'd0;
					exception_Write;
					end
	12'b01??_????_????:	begin
					code_in=31'd1;
					interrupt_in=1'd0;
					exception_Write;
					end
	12'b001?_????_????:	begin
					code_in=31'd2;
					interrupt_in=1'd0;
					exception_Write;
					end
	12'b0001_????_????:	begin
					code_in=31'd3;
					interrupt_in=1'd0;
					exception_Write;
					end
	12'b0000_1???_????:	begin
					code_in=31'd4;
					interrupt_in=1'd0;
					exception_Write;
					end
	12'b0000_01??_????:	begin
					code_in=31'd5;
					interrupt_in=1'd0;
					exception_Write;
					end
	12'b0000_001?_????:	begin
					code_in=31'd6;
					interrupt_in=1'd0;
					exception_Write;
					end
	12'b0000_0001_????:	begin
					code_in=31'd7;
					interrupt_in=1'd0;
					exception_Write;
					end
	12'b0000_0000_1???:	begin
					code_in=31'd11;
					interrupt_in=1'd0;
					exception_Write;
					end
	12'b0000_0000_01??:	begin
					code_in=31'd3;
					interrupt_in=1'd1;
					interrupt_Write;
					end	
	12'b0000_0000_001?:	begin
					code_in=31'd7;
					interrupt_in=1'd1;
					interrupt_Write;
					end	
	12'b0000_0000_0001:	begin
					code_in=31'd11;
					interrupt_in=1'd1;
					interrupt_Write;
					end						
	default：begin
					code_in=31'bx;
					interrupt_in==1'bx;
					trap_WR		<=1'b0;
					mtval_WR	<=1'b0;
			 end
	endcase
end

wire data_in;										//choose data or set bits or clear bits from register or immediate
assign data_in=CSR_OP[2]?{27'b0,data_imm},data_reg;	
reg data_wr;										//data for writing CSRRW or CSRRC or CSRRS 
always@*
begin
	casez(CSR_OP[1:0])
		begin
		`CSR_WRITE: data_wr<= data_in;
		`CSR_SET  : data_wr<= data_in |data_out;
		`CSR_CLEAR: data_wr<=~data_in &data_out;
		`CSR_NOP  : data_wr<= data_out;
		end
end

wire misa,mvendorid,marchid,mimpid,marpid,mhartid;	//which are supported to be configuration information,they should be hardwire
assign [31:0]misa=		`misa;						//hardwire
assign [31:0]mvendorid= `mvendorid;					//hardwire
assign [31:0]marchid=	`marchid;					//hardwire
assign [31:0]mimpid=	`mimpid;					//hardwire
assign [31:0]marpid=	`marpid;					//hardwire
assign [31:0]mhartid=	`mhartid;					//hardwire

reg [31:0]mhpmevent[3:31];							//event 
reg [63:0]mhpmcounter[3:31];						//event counter
genvar i;
generate for (i=3;i<32;i=i+1) begin: r_loop			//event set and event counter, when instruction equals to data in event and counter receives the instruction hand over,the event counter will add 1
	always@(posedge clk and negedge)				
		begin
			if(!rst)
				begin
				mhpmevent[i]  	<=32'b0;			//29 events reset
				mhpmcounter[i]	<=64'b0;			//29 eventcounters reset
				end
			else
				begin
				if(addr==8'b0010_0000+i && WR)		//29 events CSRRW or CSRRC or  CSRRS
				mhpmevent[i]	<=data_wr;				
				if(mhpmevent!=32'b0 && hand && instruction==mhpmevent[i])	//29 eventcounters add condition
				mhpmcounter[i]	<=mhpmcounter[i]+1'b1;
				end			
		end
								end
endgenerate

reg [63:0]mcycle,minstret;							//performance counter 
always@(posedge clk and negedge rst)
begin
	if(!rst)
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

reg  [31:0]mtval,mepc,msrach;						//parts of CSRs without hardwire bits

always@(posedge clk and negedge rst)				//mtval 
begin
	if(!rst)
	mtval<=32'b0;									//mtval reset
	else
		begin
		if(WR && addr==0x0a)						//mtval RC RS RW
			mtval<=data_wr;
		if(trap_WR)									//when the trap happens,it will record the error instruction or error memory address 
			casez(pc_in_sel)
			2'b00:mtval<=IN;
			2'b01:mtval<=IF_ID_IN;
			2'b10:mtval<=MEM_addr;
			2'b11:mtval<=ID_EXE_IN;
			endcase	
		end
end


always@(posedge clk and negedge rst)				//mepc
begin
	if(!rst)
		mepc<=32'b0;								//mepc reset
	else
		begin
		if(WR && addr==0x0b)						//mepc RW RS RC
			mepc<=data_wr;
		if(trap_WR)									//when  the trap happens,it will record the PC of error instruction or error memory address
			casez(pc_in_sel)
			2'b00:mepc<=PC;
			2'b01:mepc<=IF_ID_PC;
			2'b10:mepc<=EXE_MEM_PC;
			2'b11:mepc<=ID_EXE_PC;
			endcase
		end
end

always@(posedge clk and negedge rst)				//msrach
begin
	if(!rst)
	msrach<=32'b0;									//msrach reset
	else
	if(WR && addr==0x0e)							//msrach RW RS RC
	msrach<=data_wr;
end

wire [31:0]mip,mie,status,mcause,mtvec,mcountinhibit;	//part of CSRs which are hardwire some bits
														//MIP 
reg MEIP,MTIP,MSIP;										//register MIE for machine local interrupt enable 
assign mip[31:16]	=16'b0;								//using for platform custom interrupt
assign mip[15:12]	=4'b0;								//reserve furthur
assign mip[11]		=MEIP;								//machine extral interrupt pending
assign mip[10]		=1'b0;								//reserve furthur
assign mip[9]		=1'b0;								//supervision interrupt pending
assign mip[8]		=1'b0;								//user interrupt pending
assign mip[7]		=MTIP;								//machine miter interrupt pending
assign mip[6]		=1'b0;								//
assign mip[5]		=1'b0;								//
assign mip[4]		=1'b0;								//
assign mip[3]		=MSIP;								//machine software interrupt pending
assign mip[2]		=1'b0;								//
assign mip[1]		=1'b0;								//
assign mip[0]		=1'b0;								//
always@(posedge clk and negedge rst)
begin
	if(!rst)											//mip reset
		begin
			MEIP<=1'b0;									
			MTIP<=1'b0;										
			MSIP<=1'b0;									
		end
	else
		begin											//it is read_only,These are the interrupt pending signals
			MEIP<=External_interrupt;				
			MTIP<=Timer_interrupt;
			MSIP<=Soft_interrupt;
		end
end


reg MEIE,MTIE,MSIE;										//MIE
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
always@(posedge clk and negedge rst)					
begin
	if(!rst)											//MIE reset
		begin
		MEIE<=1'b1;
		MTIE<=1'b1;
		MSIE<=1'b1;
		end
	else
		begin
			if(WR && addr==8'h08)						//MIE RW or RS or RC
				begin
				MEIE<=data_wr[11];
				MTIE<=data_wr[7];
				MSIE<=data_wr[3];
				end
		end
end

reg MPIE,MIE;											//status
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
assign status[3]	=MIE;
assign status[2]	=1'b0;
assign status[1]	=1'b0;
assign status[0]	=1'b0;
always@(posedge clk and negedge rst)					
begin
	if(!rst)											//status reset
		begin
		MPIE<=1'b1;
		MIE <=1'b1;
		end
	else
		begin	
		if(WR && addr==8'h07)							//status RW or RS or RC
			begin
			MPIE<=data_wr[7];
			MIE <=data_wr[3];
			end
		if(trap_WR)										//MIE is global interrupt enable;when trap happens ,global interrupt enable will turn off
			begin
			MPIE<=MIE;
			MIE <=1'b0;
			end
		if(mret)
			begin
			MPIE<=1'b1;
			MIE <=MPIE;
		end
end

reg INTERRUPT;											//mcause
reg [30:0]CODE;
assign mcause[31]	=INTERRUPT;
assign mcause[30:0]	=CODE;
always@(posedge clk and negedge rst)
begin
	if(!rst)											//mcause reset
		begin
		INTERRUPT<=1'b0;
		CODE<=31'b0;
		end
	else
		begin
			if(WR && addr==8'h0c)						//mcause RW RS RC
				begin
				INTERRUPT<=data_wr[31]
				CODE     <=data_wr[30:0]
				end
			if(trap_WR)									//
				begin
				INTERRUPT<=interrupt_in;
				CODE     <=code_in;
				end
		end
end

reg[29:0]BASE;											//mtvec
reg[1:0]MODE;
assign mtvec[31:2]=BASE;
assign mtvec[1:0]=MODE;
always@(posedge clk and negedge rst)
begin
	if(!rst)
		begin
		BASE<=`BASE;
		MODE<=2'b01;
		end
	else
		begin
			if(WR && addr==8'h0d)
				begin
				BASE<=data_wr[31:1];
				CODE<=data_wr[1:0];
				end
		end
end
reg [31:0]trap_PC_next;
always@*
begin
case(mode)
`base_mode  : trap_PC_next=`BASE;
`vector_mode: begin
		 if(INTERRUPT)
			trap_PC_next=`BASE+CODE<<2;
		 else
			trap_PC_next=`BASE;
		 end
default：begin
			trap_PC_next=`BASE;
		 end
end

reg [28:0]HPM;											//mcountinhibit
reg IR,TM,CY;
assign mcountinhibit[31:3]=HPM;
assign mcountinhibit[2]=IR;
assign mcountinhibit[1]=TM;
assign mcountinhibit[0]=CY;
always@(posedge clk and negedge rst)
begin
	if(!rst)
		begin
		HPM<=29'b0;
		IR<=1'b0;
		TM<=1'b0;
		CY<=1'b0;
		end
	else
		begin
			if(WR && addr==8'h13)
				begin
				HPM<=data_wr[31:3];
				IR <=data_wr[2];
				TM <=data_wr[1];
				CY <=data_wr[0];
				end
		end
end


always @*												//register map
begin
	casez(addr)
	8'h01: data_out<=misa;
	8'h02: data_out<=mvendorid;
	8'h03: data_out<=marchid;
	8'h04: data_out<=mimpid;
	8'h05: data_out<=marpid;
	8'h06: data_out<=mhartid;
	8'h07: data_out<=status;
	8'h08: data_out<=mie;
	8'h09: data_out<=mip;
	8'h0a: data_out<=mtval;
	8'h0b: data_out<=mepc;
	8'h0c: data_out<=mcause;
	8'h0d: data_out<=mtvec;
	8'h0e: data_out<=msrach;
	8'h0f: data_out<=mcycle[31:0];
	8'h10: data_out<=mcycle[63:32];
	8'h11: data_out<=minstret[31:0];
	8'h12: data_out<=minstret[63:31];
	8'h13: data_out<=mcountinhibit;
	8'b0010_00??: data_out<=32'b0;
	8'b001?_????: data_out<=mhpmevent[addr[4:0]];
	8'b0100_00??: data_out<=32'b0;
	8'b010?_????: data_out<=mhpmcounter[addr[4:0]][63:32];
	8'b0110_00??: data_out<=32'b0;
	8'b011?_????: data_out<=mhpmcounter[addr[4:0]][31:0]; 
	default：
	data_out<=32'bx;
	endcase
end
