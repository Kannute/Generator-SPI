`timescale 1ns / 1ps

/*
Dodano output rdySpi, który informuje, 
kiedy SPI przestaje przesy?a? dane
*/
module SPI #(parameter nrbit = 16)(
    input clk,
    input rst,
    input str,
    output sclk,
    output logic d0,
    output sync,
    input [7:0] generatedValue,
    output rdySpi
    );
    
    localparam cb = $clog2(nrbit);
    
    typedef enum {idle, start, data, highz} states_e;
    states_e st, nst;

    logic [3:0] cdiv;
    logic [cb:0] bcnt;
    logic [nrbit-1:0] shreg;
    
    assign sync = (st == idle);
    assign sclk = cdiv[3];
 
    always @(posedge clk, posedge rst) 
        if (rst)
            cdiv <= 4'b0;
        else if (st == idle)
            cdiv <= 4'b0;
        else 
            cdiv <= cdiv + 1'b1;
 
    logic t;
    wire en = t & ~sclk;
    

    always @(posedge clk, posedge rst) 
        if (rst)
            t <= 1'b0;
        else 
            t <= sclk;
 
    always @(posedge clk, posedge rst) 
        if (rst)
            st <= idle;
        else 
            st <= nst;
 
    always_comb begin
        nst = idle;
        case(st)
        
            idle: nst = str ? start : idle;
            start: nst = data;
            data: nst = (bcnt == nrbit) ? idle : data; 

        endcase
    end 
 
    always @(posedge clk, posedge rst) 
        if (rst)
            bcnt <= {(cb+1){1'b0}};

        else if (bcnt == nrbit)
            bcnt <= {(cb+1){1'b0}}; 
        else if (en) 
            bcnt <= bcnt + 1'b1;
 
    assign d0 = shreg[15];
    
    always @(posedge clk, posedge rst) 
        if (rst)
            shreg <= {16'b0};
        else if (en & st == data)
            shreg <= {shreg[nrbit-2:0], 1'b0};
        else if (st == start)
            shreg <= {8'b0,generatedValue};
           
     assign rdySpi = (st == idle) ? 1'b1 : 1'b0;
        
 
endmodule
 