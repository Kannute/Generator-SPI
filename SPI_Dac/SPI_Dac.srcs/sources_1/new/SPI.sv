module SPI #(parameter nrbit = 16)(
    input clk,
    input rst,
    input str,
    output sclk,
    output logic d0,
    output sync
    );
    
    localparam cb = $clog2(nrbit);
    
    typedef enum {idle, start, data, highz} states_e;
    states_e st, nst;
    
    logic [3:0] cdiv;
    logic [cb:0] bcnt;
    logic [nrbit-1:0] shreg;
    
    initial
        begin 
           // shreg <= {8'b0, 1'b1, 7'b0};
           shreg <= 16'b1;
        end
        
    assign chip_select = (st == idle);
    assign sclk = ~cdiv[3];
 
    always @(posedge clk, posedge rst) 
        if (rst)
            cdiv <= 4'b0;
        else if (st == idle)
            cdiv <= 4'b0;
        else 
            cdiv <= 4'b1;
 
    logic t;
    wire en = ~t & sclk;
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
            start: nst = (bcnt == 3) ? data : start;
            data: nst = (bcnt == nrbit - 1) ? highz : data; 
            highz: nst = (bcnt == nrbit) ? idle : highz;
        endcase
    end 
 
    always @(posedge clk, posedge rst) 
        if (rst)
            bcnt <= {(cb+1){1'b0}};
        else if (str)
            bcnt <= {(cb+1){1'b0}};
        else if (en) 
            bcnt <= bcnt + 1'b1;
 
    assign d0 = shreg[nrbit-1];
    
    always @(posedge clk, posedge rst) 
        if (rst)
            shreg <= {(nrbit-1){1'b0}};
        else if (en & st == data)
            shreg <= {shreg[nrbit-1:0], 1'b0};
        else if (st == start)
            shreg <= {(nrbit - 1){1'b0}};
      
 
endmodule
 