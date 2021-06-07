`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
Dodana maszyna stanów.
Liczby zostaj? wygenerowane, a nast?pnie wysy?ane po 
jednym wci?ni?ciu przycisku str.
*/

module top #(parameter nrbit = 16)(
    input clk,
    input rst,
    input str,
    /* 
    ver - liczba okre?laj?ca rodzaj przesylanego sygnalu
    00 - dane rosn?ce liniowo
    01 - dane kwadratowe => albo maxValue albo zero
    10 - sinus
    */
    input logic [1:0] ver, 
    output sclk,
    output logic d0,
    output sync
    );
 wire [7:0] generatedValue;
 wire rdySpi;
 
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

endmodule