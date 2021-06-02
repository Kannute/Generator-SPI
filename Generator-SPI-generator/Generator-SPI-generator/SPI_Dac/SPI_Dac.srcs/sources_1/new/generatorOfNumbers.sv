`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module generatorOfNumbers(
    input clk,
    input rst,
    input en,
    output logic [7:0] outputValue
    );
    logic[7:0] maxValue;
    logic[7:0] currentValue;

    always @(posedge clk, posedge rst) 
        if (rst)
            maxValue = 255;
     
    always @(posedge clk, posedge rst) 
        if (rst)
            begin
            currentValue = 8'b0;
            end
        else if(en)
            if(currentValue == maxValue)
                currentValue += 8'b0;
            else    
                currentValue += 1'b1;
                
            
                
    always @(posedge clk, posedge rst)
        if(rst)
             outputValue <= 8'b0;
        else if(currentValue == maxValue)
            outputValue <= 8'b0;
        else
           outputValue <= currentValue;
           //outputValue <= {1'b1, 7'b0};



endmodule
