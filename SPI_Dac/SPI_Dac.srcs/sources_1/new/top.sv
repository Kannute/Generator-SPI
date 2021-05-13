`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Create Date: 13.05.2021 12:57:04
// Design Name: 
// Module Name: top

//////////////////////////////////////////////////////////////////////////////////


module top #(parameter nrbit = 16)(
    input clk,
    input rst,
    input str,
    output sclk,
    output logic d0,
    output sync);

 SPI #(.nrbit(nrbit)) dacspi(
     .clk(clk),
     .rst(rst),
     .str(str),
     .sclk(sclk),
     .d0(d0),
     .sync(sync)
    );
    
endmodule
