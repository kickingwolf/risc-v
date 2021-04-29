module csr_register();

input Instruction_address_misaligned;	//exception
input Instruction_access_fault;			//exception
input Illegal_instruction;				//exception
input Breakpoint;						//exception
input Load_address_misaligned;			//exception
input Load_access_fault;				//exception
input Store_address_misaligned;			//exception
input Store_access_fault;				//exception
input Ecall; 							//exception

input Soft_interrupt;					//interrupt
input Timer_interrupt;					//interrupt
input External_interrupt;				//interrupt

input data_reg;
input data_imm;
input addr;
input WR;
output data_out;

wire data_in;
assign data_in=CSR_OP[2]?{27'b0,data_imm},data_reg;
reg data_wr;
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

wire misa,mvendorid,marchid,mimpid,marpid,mhartid;

assign [31:0]misa=		`misa;			//hardwire
assign [31:0]mvendorid= `mvendorid;		//hardwire
assign [31:0]marchid=	`marchid;		//hardwire
assign [31:0]mimpid=	`mimpid;		//hardwire
assign [31:0]marpid=	`marpid;		//hardwire
assign [31:0]mhartid=	`mhartid;		//hardwire

reg [31:0]mhpmevent[3:31];				//counter
reg [63:0]mhpmcounter[3:31];			//counter
genvar i;
generate for (i=3;i<32;i=i+1) begin: r_loop
	always@(posedge clk and negedge)
		begin
			if(!rst)
				begin
				mhpmevent[i]  	<=32'b0;
				mhpmcounter[i]	<=64'b0;
				end
			else
				begin
				if(addr==8'b0010_0000+i && WR)
				mhpmevent[i]	<=data_wr;
				if(mhpmevent!=32'b0 && hand && instruction==mhpmevent[i])
				mhpmcounter[i]	<=mhpmcounter[i]+1'b1;
				end			
		end
								end
endgenerate
reg [63:0]mcycle,minstret;				//counter 
always@(posedge clk and negedge rst)
begin
	if(!rst)
		begin
			mcycle<=64'b0;
			minstret<=64'b0;
		end
	else
		begin
			mcycle<=mcycle+1'b1;
			if(hand)
			minstret<=minstret+1'b1;
		end
end

wire [31:0]mip,mie,status,mcause,mtvec,mcountinhibit;
reg  [31:0]mtval,mepc,msrach;
always@(posedge clk and negedge rst)
begin
	if(!rst)
	mtval<=32'b0;
	else
	if(WR && addr==0x0a)
	mtval<=data_wr;
end

always@(posedge clk and negedge rst)
begin
	if(!rst)
	mepc<=32'b0;
	else
	if(WR && addr==0x0a)
	mepc<=data_wr;
end

always@(posedge clk and negedge rst)
begin
	if(!rst)
	msrach<=32'b0;
	else
	if(WR && addr==0x0a)
	msrach<=data_wr;
end

reg MEIP,MTIP,MSIP;					//register MIE for machine local interrupt enable 
assign mip[31:16]	=16'b0;				//using for platform custom interrupt
assign mip[15:12]	=4'b0;				//reserve furthur
assign mip[11]		=MEIP;				//machine extral interrupt pending
assign mip[10]		=1'b0;				//reserve furthur
assign mip[9]		=1'b0;				//supervision interrupt pending
assign mip[8]		=1'b0;				//user interrupt pending
assign mip[7]		=MTIP;				//machine miter interrupt pending
assign mip[6]		=1'b0;				//
assign mip[5]		=1'b0;				//
assign mip[4]		=1'b0;				//
assign mip[3]		=MSIP;				//machine software interrupt pending
assign mip[2]		=1'b0;				//
assign mip[1]		=1'b0;				//
assign mip[0]		=1'b0;				//

always@(posedge clk and negedge rst)
begin
	if(!rst)
		begin
			MEIP<=1'b0;
			MTIP<=1'b0;
			MSIP<=1'b0;
		end
	else
		begin
			MEIP<=External_interrupt;
			MTIP<=Timer_interrupt;
			MSIP<=Soft_interrupt;
		end
end


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
always@(posedge clk and negedge rst)
begin
	if(!rst)
		begin
		MEIE<=1'b1;
		MTIE<=1'b1;
		MSIE<=1'b1;
		end
	else
		begin
			if(WR && addr==8'h08)
				begin
				MEIE<=data_wr[11];
				MTIE<=data_wr[7];
				MSIE<=data_wr[3];
				end
		end
end

reg MPIE,MIE;
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
	if(!rst)
		begin
		MPIE<=1'b1;
		MIE <=1'b1;
		end
	else
		if(WR && addr==8'h07)
			begin
			MPIE<=data_wr[7];
			MIE <=data_wr[3];
			end
end

reg INTERRUPT;
reg [30:0]CODE;
assign mcause[31]	=INTERRUPT;
assign mcause[30:0]	=CODE;
always@(posedge clk and negedge rst)
begin
	if(!rst)
		begin
		INTERRUPT<=1'b0;
		CODE<=31'b0;
		end
	else
		begin
			if(WR && addr==8'h0c)
				begin
				INTERRUPT<=data_wr[31]
				CODE     <=data_wr[30:0]
				end
		end
end

reg[29:0]BASE;
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


reg [28:0]HPM;
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

//reg_MMP
always @*
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
