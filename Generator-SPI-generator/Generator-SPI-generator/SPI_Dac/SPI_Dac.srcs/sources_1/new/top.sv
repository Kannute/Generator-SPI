`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
Dodana maszyna stanów.
Liczby zostaj? wygenerowane, a nast?pnie wysy?ane po 
jednym wci?ni?ciu przycisku str.
*/

module top #(parameter nrbit = 16, mdeep = 16)(
    input clk,
    input rst,
    input str,
    /* 
    ver - liczba okre?laj?ca rodzaj przesylanego sygnalu
    00 - dane rosn?ce liniowo
    01 - dane kwadratowe => albo maxValue albo zero
    10 - sinus
    */
    output sclk,
    output logic d0,
    output sync,
    input rx, 
    output tx
    );
wire [7:0] generatedValue;
wire rdySpi;
wire [3 : 0] s_axi_awaddr, s_axi_araddr;
wire [31 : 0] s_axi_wdata, s_axi_rdata;
wire [1 : 0] s_axi_bresp, s_axi_rresp;
wire [3 : 0] s_axi_wstrb = 4'b1111;
wire [1:0] ver;

logic [$clog2(mdeep)-1:0] adr;
logic [7:0] dato,dati;

 typedef enum {idle, start_g, wait1, start_spi, data} states_e;
 states_e st, nst;
 
 always @(posedge clk, posedge rst) 
        if (rst)
            st <= idle;
        else 
            st <= nst;
 
    always_comb begin
        nst = idle;
        case(st)
            idle: nst = str ? start_g : idle;
            start_g: nst = wait1;
            wait1: nst = start_spi;
            start_spi : nst = data;
            data : nst = rdySpi ? start_g : data; 
        endcase
    end 
/*
SPI zaczyna prac?, gdy st == star_spi
*/
 SPI #(.nrbit(nrbit)) dacspi(
     .clk(clk),
     .rst(rst),
     .str(st == start_spi),
     .sclk(sclk),
     .d0(d0),
     .sync(sync),
     .generatedValue(generatedValue),
     .rdySpi(rdySpi)
    );
 
 /*
 Generator generuje kolejn? liczb?, 
 gdy st == start_g
 */
  generatorOfNumbers generator(
        .clk(clk),
        .rst(rst),
        .en(st == start_g),
        .ver(ver),
        .outputValue(generatedValue)
        );
        
decoder vd (.clk(clk), .rst(rst), .dat_in(dato), .dat_decoded(ver));

axi_uartlite_slave uart_axi (
  .s_axi_aclk(clk),        // input wire s_axi_aclk
  .s_axi_aresetn(~rst),  // input wire s_axi_aresetn
  .interrupt(),          // output wire interrupt
  .s_axi_awaddr(s_axi_awaddr),    // input wire [3 : 0] s_axi_awaddr
  .s_axi_awvalid(s_axi_awvalid),  // input wire s_axi_awvalid
  .s_axi_awready(s_axi_awready),
    // output wire s_axi_awready
  .s_axi_wdata(s_axi_wdata),      // input wire [31 : 0] s_axi_wdata
  .s_axi_wstrb(s_axi_wstrb),      // input wire [3 : 0] s_axi_wstrb
  .s_axi_wvalid(s_axi_wvalid),    // input wire s_axi_wvalid
  .s_axi_wready(s_axi_wready),  
    // output wire s_axi_wready
  .s_axi_bresp(s_axi_bresp),      // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid(s_axi_bvalid),    // output wire s_axi_bvalid
  .s_axi_bready(s_axi_bready), 
     // input wire s_axi_bready
  .s_axi_araddr(s_axi_araddr),    // input wire [3 : 0] s_axi_araddr
  .s_axi_arvalid(s_axi_arvalid),  // input wire s_axi_arvalid
  .s_axi_arready(s_axi_arready), 
   // output wire s_axi_arready
  .s_axi_rdata(s_axi_rdata),      // output wire [31 : 0] s_axi_rdata
  .s_axi_rresp(s_axi_rresp),      // output wire [1 : 0] s_axi_rresp
  .s_axi_rvalid(s_axi_rvalid),    // output wire s_axi_rvalid
  .s_axi_rready(s_axi_rready),    // input wire s_axi_rready
  .rx(rx),                        // input wire rx
  .tx(tx)                        // output wire tx  
);


master_axi # (.deep(mdeep)) master ( .clk(clk), .rst(rst),
    .wadr(s_axi_awaddr), .awvld(s_axi_awvalid), .awrdy(s_axi_awready),
    .wdat(s_axi_wdata), .wvld(s_axi_wvalid), .wrdy(s_axi_wready),
    .brsp(s_axi_bresp), .bvld(s_axi_bvalid), .brdy(s_axi_bready),
    .radr(s_axi_araddr), .arvld(s_axi_arvalid), .arrdy(s_axiarready),
    .rdat(s_axi_rdata), .rvld(s_axi_rvalid), .rrdy(s_axi_rready),
    .data_rec(dati), .data_tr(dato), .addr(adr), .wr(wr), .rd(rd));

memory # (.deep(mdeep))mem(.clk(clk),.addr(adr),.data_in(dati), .data_out(dato),.rd(rd), .wr(wr));

endmodule