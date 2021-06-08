`timescale 1ns / 1ps

module sinus_gen(
    input clk, rst ,
    input enable,
    output reg [7:0] sinus
    );
    parameter SIZE = 256;
    reg [7:0] rom_memory [SIZE-1:0];
    integer i;
    initial 
        $readmemh("sine.mem", rom_memory); //File with the signal

    //At every positive edge of the clock, output a sine wave sample.
    always@(posedge clk)
        begin
            if(enable) begin
                sinus <= rom_memory[i];
            end
        end
        
        always@(posedge clk, posedge rst)
            if(rst)
                i <= 0;
            else if(enable) begin
                i <= i+ 1;
                if(i == SIZE)
                    i <= 0;
            end

endmodule