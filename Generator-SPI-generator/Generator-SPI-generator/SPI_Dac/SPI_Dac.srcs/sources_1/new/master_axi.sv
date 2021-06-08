`timescale 1ns / 1ps

module master_axi #(parameter deep = 16) (input clk, rst,
    output logic [3:0] wadr, output logic awvld, input awrdy,
    output [31:0] wdat, output logic wvld, input wrdy,
    input [1:0] brsp, input bvld, output logic brdy,
    output logic [3:0] radr, output logic arvld, input arrdy,
    input [31:0] rdat, input rvld, output logic rrdy,
    output logic [7:0] data_rec, input logic [7:0] data_tr,
    output logic [$clog2(deep)-1:0] addr, output logic rd, wr);
    
localparam nb = $clog2(deep);
typedef enum {readstatus, waitstatus, read, waitread, write, waitwrite, waitresp, clear} states_e;
states_e st, nst;

wire addr0 = (addr=={nb{1'b0}});
wire rfifo_valid = (st == waitstatus & rvld)?rdat[0]:1'b0;        
wire tfifo_full = (st == waitstatus & rvld)?rdat[3]:1'b0;    

logic rec_trn;
always @(posedge clk, posedge rst)
    if(rst)
        rec_trn <= 1'b1;
    else if (addr == deep)
        rec_trn <= 1'b0;
    else if (st == clear)
        rec_trn <= 1'b1;

wire inca = ((st == waitread) & rvld & rec_trn);
wire deca = ((st == waitwrite) & wrdy & ~rec_trn);

always @(posedge clk, posedge rst)
    if(rst)   
        addr <= {nb{1'b0}};
    else if (inca)    //read
        addr <= addr + 1;
    else if (deca)    //write
        addr <= addr - 1;
    else if (st == clear)
        addr <= {nb{1'b0}};         

always @(posedge clk, posedge rst)
    if(rst)
        st <= readstatus;
    else
        st <= nst;
        
always_comb begin
    nst = readstatus;
    case(st)
        readstatus: nst = waitstatus;
        waitstatus: if(rec_trn)
                        nst = rfifo_valid?(rvld?read:waitstatus):readstatus;
                    else
                        nst = tfifo_full?readstatus:(rvld?write:waitstatus);
        read: nst = waitread;
        waitread: nst = rvld?readstatus:waitread;
        write: nst = waitwrite;
        waitwrite: nst = awrdy?waitresp:waitwrite;
        waitresp: nst = bvld?(addr0?clear:readstatus):waitresp;
        clear: nst = readstatus;
    endcase
end


//channel AR
always @(posedge clk, posedge rst)
    if(rst)  
        radr <= 4'b0;
    else if (st == readstatus)
        radr <= 4'h8;
    else if (st == read)
        radr <= 4'h0;   
always @(posedge clk, posedge rst)
    if(rst)         
        arvld <= 1'b0;
    else if(st == read | st == readstatus)
        arvld <= 1'b1;
    else if(arrdy)
        arvld <= 1'b0;
        
//channel R
always @(posedge clk, posedge rst)
    if(rst)        
        rrdy <= 1'b0;
    else if((st == waitstatus | st == waitread) & rvld)
        rrdy <= 1'b1;  
    else //if(st == read | st == readstatus)
        rrdy <= 1'b0;  
always @(posedge clk, posedge rst)
    if(rst)
        data_rec <= 8'b0;
    else if (inca)
        data_rec <= rdat[7:0];
//memory write 
always @(posedge clk)   //, posedge rst)
    if(rst)
        wr <= 1'b0;
    else 
        wr <= inca;


//channel AW
always @(posedge clk, posedge rst)
    if(rst)  
        wadr <= 4'b0;
    else if (st == write | st == waitwrite)
        wadr <= 4'h4;
    else
        wadr <= 4'b0;
always @(posedge clk, posedge rst)
    if(rst)         
        awvld <= 1'b0;
    else begin
        if(st == waitwrite)
            awvld <= 1'b1;
        if(awrdy)
            awvld <= 1'b0; 
        end        

//channel W
always @(posedge clk, posedge rst)
    if(rst)         
        wvld <= 1'b0;
    else begin
        if(st == waitwrite)
            wvld <= 1'b1;
        if(awrdy)
            wvld <= 1'b0; 
        end
assign wdat = (st == waitwrite)?{24'b0, data_tr}:32'b0;

//channel B
always @(posedge clk, posedge rst)
    if(rst)        
        brdy <= 1'b0;
    else begin
        if (st == write)
            brdy <= 1'b1;  
        if (bvld)
            brdy <= 1'b0;
        end
//memory read        
always @(posedge clk, posedge rst)
    if(rst)
        rd <= 1'b0;
    else 
        rd <= (st == write);  
                                      
endmodule