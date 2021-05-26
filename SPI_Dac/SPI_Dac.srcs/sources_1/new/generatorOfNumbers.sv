`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module generatorOfNumbers(
    input clk,
    input rst,
    input en,
    output logic [7:0] outputValue,
    output logic sending
    );
    logic[7:0] maxValue;
    logic[7:0] currentValue;
    
    always @(posedge clk, posedge rst) 
        if (rst)
            maxValue = 255;
     
    always @(posedge clk, posedge rst) 
        if (rst)
            begin
            currentValue = {7'b0,1'b1};
            sending = 1'b0; 
            end
        else if(en)
            if(currentValue == maxValue)
                sending = 1'b0;
            else
                begin
                currentValue += 1'b1;
                sending = 1'b1;   
                end
            
                
    always @(posedge clk, posedge rst)
        if(rst)
             outputValue <= {7'b0,1'b1};
        else if(sending)
            outputValue <= currentValue;
        else
            outputValue <= 8'b0;
endmodule
