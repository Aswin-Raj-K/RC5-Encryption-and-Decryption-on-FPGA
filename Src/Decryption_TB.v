//Github-Copilot was not used
`timescale 1ns / 1ps
`define NULL 0
module Decryption_TB();


reg clr,clk=0,din_valid;
reg [63:0]din, exp_dout;
wire dout_ready;
wire [63:0]dout; 
integer data_file;


Decryption DUT(
clr, 
clk, 
din_valid,
din,   
dout_ready,
dout);

always
    #10 clk = ~clk;

initial
    begin
        clr = 0;
        #20
        clr = 1;
        data_file = $fopen("testCases.mem", "r");
        if (data_file == `NULL) begin
            $display("data_file handle was NULL");
            $finish;
        end
        $display("=========RESULT==========");
        while(!$feof(data_file))
            begin
            $fscanf(data_file, "%h %h", exp_dout,din);
            din_valid = 1;
            #20;
            din_valid = 0;  
            wait(dout_ready==1);
            #40;  
            if(exp_dout!=dout)
            begin
                $display("exp_dout = %d",exp_dout);
                $display("dout = %d",dout);
                $display("=========================");
                $display("STATUS : Failed");
                $display("=========================");
                $fclose(data_file);
                $finish;
            end
        end
        $display("STATUS : Successfull, All Test Cases Passed");
        $display("=========================");
        $fclose(data_file);
        $finish;
    end

endmodule
