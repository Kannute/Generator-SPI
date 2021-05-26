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
    localparam hp = 5, d = 7;
    localparam nrbit = 16;
    logic clk, rst, str, sclk;
    logic sclk, d0, sync;
    
    logic [7:0] generatedValue;
    logic valueIsSent;
    top #(.nrbit(nrbit)) topmodule (
     .clk(clk),
     .rst(rst),
     .str(str),
     .sclk(sclk),
     .d0(d0),
     .sync(sync)
     );

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
        str = 1'b0;
        repeat(2*d) @(posedge clk);
        #1 str = 1'b1;
        repeat(3) @(posedge clk);
        #5 str = 1'b0;
    end

    initial begin
        repeat(8*d) @(posedge clk);
        $finish;
    end
endmodule
