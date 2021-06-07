`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module generatorOfNumbers(
    input clk,
    input rst,
    input en,
    input logic [1:0] ver,
    output logic [7:0] outputValue
    );


    logic[7:0] maxValue;
    logic[7:0] currentValue;
    logic [7:0] sineValue;
    sinus_gen singen (.clk(clk) , .sinus(sineValue), .enable(en) );
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
                currentValue = 8'b0;
            else
                case(ver)
                    0: currentValue += 1'b1;
                    1:
                        begin
                            if(currentValue == maxValue-1)
                                currentValue = 8'b0;
                            else
                                currentValue = maxValue-1;
                        end
                    2: currentValue = sineValue;
                endcase 




    always @(posedge clk, posedge rst)
        if(rst)
             outputValue <= 8'b0;
        else if(currentValue == maxValue)
            outputValue <= 8'b0;
        else
           outputValue <= currentValue;
           //outputValue <= {1'b1, 7'b0};



endmodule