`timescale 1ns / 1ps

module decoder(
    input rst,
    input clk,
    input [7:0] dat_in,
    output logic [1:0] dat_decoded
    );
    
    always@(posedge clk, rst)
    begin
        if(rst)
            dat_decoded <= 2'b00;
        else
            dat_decoded <= dat_in[1:0];
    end
    
endmodule
