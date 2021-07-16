module plic
(
input rst_n,
input clk,
input wr_H_rd_L,
input load,
input [14:0]src,
input [31:0]wdata,
input [2:0]addr,
output[31:0]rdata,
output irq
);
wire [14:0]el;
wire [14:0]ie;
wire [44:0]PW;
wire [2:0]TH;
wire [3:0]id;
wire claim;
wire complete;

 PLIC_reg init(
.rst_n(rst_n),
.clk(clk),
.wr_H_rd_L(wr_H_rd_L),
.load(load),
.wdata(wdata),
.addr(addr),
.rdata(rdata),

.el(el),
.ie(ie),
.PW(PW),
.TH(TH),
.id(id),
.claim(claim),
.complete(complete)
);


  /** Hookup PLIC Core
   */
  plic_core 
  plic_core_inst (
    .rst_n     ( rst_n  ),
    .clk       ( clk    ),

    .src       ( src      ),
    .el        ( el       ),
    .ie        ( ie       ),
    .ipriority ( PW        ),
    .threshold ( TH      ),

    .ireq      ( irq      ),
    .id        ( id       ),
    .claim     ( claim    ),
    .complete  ( complete )
  );

endmodule