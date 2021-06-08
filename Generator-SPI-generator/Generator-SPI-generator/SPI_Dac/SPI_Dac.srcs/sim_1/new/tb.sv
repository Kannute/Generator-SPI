`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.05.2021 12:53:44
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb();
    localparam d = 20, hp = 5, fclk = 100_000_000, br = 230400, size = 8;
    localparam ratio = fclk / br - 1;
    localparam nrbit = 16;
    logic clk, rst, str, rx, tx;
    logic sclk, d0, sync;
    logic [7:0] generatedValue;
    logic valueIsSent;
    wire fint;
    top #(.nrbit(nrbit) , .mdeep(d)) topmodule (
     .clk(clk),
     .rst(rst),
     .str(str),
     .sclk(sclk),
     .d0(d0),
     .sync(sync),
     .tx(tx),
     .rx(rx)
     );
    
////------------------------------------------------------
////  DAC output observation
////------------------------------------------------------
//    always @(negedge dac_cs) begin
//        sclk = 0;
//        dacsh <= 12'b0;
//    end
    
//    event dac_sclk_12;
//    always @(negedge dac_sclk) begin
//        ndacsclk++;
//        if(ndacsclk > 12 && ndacsclk < 25)
//            -> dac_sclk_12;
//    end
    
//    always @(dac_sclk_12 )
//        dacsh <= {dacsh[nrbits-2:0], d0};
    
//    always @(posedge dac_cs)
//        sigout <= dacsh;    
    initial begin
        clk = 1'b0;
        forever #hp clk = ~clk;

    end

    initial begin
        rst = 1'b0;
        #1 rst = 1'b1;
        #3 rst = 1'b0;


    end 

    initial begin
        #0 str = 1'b0;
        #1 str = 1'b1;
        #5 str = 1'b0; 
    end

//    /*
//    Ver poczatkowo ustawiony na 0 - sygnal liniowy
//    1 - sygnal kwadratowy
//    2 - sygnal sinusoidalny
//    */
//   initial begin
//    #0 ver = 2'b10;
////    #250000 ver = 2'b1;
////    #250000 ver = 2;
//   end

   
   
    simple_transmitter #(.nb(size), .deep(d),.ratio(ratio)) transmitter(.clk(clk), .rst(rst), .str(str), .trn(rx), .fin(fint));
        
endmodule