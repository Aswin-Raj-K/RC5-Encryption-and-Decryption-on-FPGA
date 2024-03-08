//Github-Copilot was not used
`timescale 1ns / 1ps
module Decryption(
input clr, clk, din_valid,
input [63:0]din,
output dout_ready,
output [63:0]dout);

reg [3:0]i_cnt;
reg [31:0]a_reg, b_reg;
wire [31:0]b_sub, a_sub, a_out,b_out;
wire [31:0]a_rot, b_rot,a_xor,b_xor;
reg [31:0]rom[25:0];

parameter ST_IDLE = 0, ST_PRE_ROUND = 1, ST_ROUND_OP = 2, ST_READY = 3;
reg [1:0]state;

initial begin
    rom[0] = 'h0;
    rom[1] = 'h0;
    rom[2] = 'h46F8E8C5;
    rom[3] = 'h460C6085;
    rom[4] = 'h70F83B8A;
    rom[5] = 'h284B8303;
    rom[6] = 'h513E1454;
    rom[7] = 'hF621ED22;
    rom[8] = 'h3125065D;
    rom[9] = 'h11A83A5D;
    rom[10] = 'hD427686B;
    rom[11] = 'h713AD82D;
    rom[12] = 'h4B792F99;
    rom[13] = 'h2799A4DD;
    rom[14] = 'hA7901C49;
    rom[15] = 'hDEDE871A;
    rom[16] = 'h36C03196;
    rom[17] = 'hA7EFC249;
    rom[18] = 'h61A78BB8;
    rom[19] = 'h3B0A1D2B;
    rom[20] = 'h4DBFCA76;
    rom[21] = 'hAE162167;
    rom[22] = 'h30D76B0A;
    rom[23] = 'h43192304;
    rom[24] = 'hF6CC1431;
    rom[25] = 'h65046380;
end 

assign a_out = a_reg-rom[0];
assign b_out = b_reg-rom[1];
assign dout = {a_out,b_out};
assign dout_ready = state==ST_READY?1'b1:1'b0;

//Combinational Logic Block B
assign b_sub = b_reg-rom[{i_cnt,1'b1}];
assign b_rot =  
(a_reg[4:0]==1)?{b_sub[0],b_sub[31:1]}:
(a_reg[4:0]==2)?{b_sub[1:0],b_sub[31:2]}:
(a_reg[4:0]==3)?{b_sub[2:0],b_sub[31:3]}:
(a_reg[4:0]==4)?{b_sub[3:0],b_sub[31:4]}:
(a_reg[4:0]==5)?{b_sub[4:0],b_sub[31:5]}:
(a_reg[4:0]==6)?{b_sub[5:0],b_sub[31:6]}:
(a_reg[4:0]==7)?{b_sub[6:0],b_sub[31:7]}:
(a_reg[4:0]==8)?{b_sub[7:0],b_sub[31:8]}:
(a_reg[4:0]==9)?{b_sub[8:0],b_sub[31:9]}:
(a_reg[4:0]==10)?{b_sub[9:0],b_sub[31:10]}:
(a_reg[4:0]==11)?{b_sub[10:0],b_sub[31:11]}:
(a_reg[4:0]==12)?{b_sub[11:0],b_sub[31:12]}:
(a_reg[4:0]==13)?{b_sub[12:0],b_sub[31:13]}:
(a_reg[4:0]==14)?{b_sub[13:0],b_sub[31:14]}:
(a_reg[4:0]==15)?{b_sub[14:0],b_sub[31:15]}:
(a_reg[4:0]==16)?{b_sub[15:0],b_sub[31:16]}:
(a_reg[4:0]==17)?{b_sub[16:0],b_sub[31:17]}:
(a_reg[4:0]==18)?{b_sub[17:0],b_sub[31:18]}:
(a_reg[4:0]==19)?{b_sub[18:0],b_sub[31:19]}:
(a_reg[4:0]==20)?{b_sub[19:0],b_sub[31:20]}:
(a_reg[4:0]==21)?{b_sub[20:0],b_sub[31:21]}:
(a_reg[4:0]==22)?{b_sub[21:0],b_sub[31:22]}:
(a_reg[4:0]==23)?{b_sub[22:0],b_sub[31:23]}:
(a_reg[4:0]==24)?{b_sub[23:0],b_sub[31:24]}:
(a_reg[4:0]==25)?{b_sub[24:0],b_sub[31:25]}:
(a_reg[4:0]==26)?{b_sub[25:0],b_sub[31:26]}:
(a_reg[4:0]==27)?{b_sub[26:0],b_sub[31:27]}:
(a_reg[4:0]==28)?{b_sub[27:0],b_sub[31:28]}:
(a_reg[4:0]==29)?{b_sub[28:0],b_sub[31:29]}:
(a_reg[4:0]==30)?{b_sub[29:0],b_sub[31:30]}:
(a_reg[4:0]==31)?{b_sub[30:0],b_sub[31]}:
b_sub;
assign b_xor = b_rot ^ a_reg; 

//Combinational Logic Block A
assign a_sub = a_reg-rom[{i_cnt,1'b0}];
assign a_rot =  
(b_xor[4:0]==1)?{a_sub[0],a_sub[31:1]}:
(b_xor[4:0]==2)?{a_sub[1:0],a_sub[31:2]}:
(b_xor[4:0]==3)?{a_sub[2:0],a_sub[31:3]}:
(b_xor[4:0]==4)?{a_sub[3:0],a_sub[31:4]}:
(b_xor[4:0]==5)?{a_sub[4:0],a_sub[31:5]}:
(b_xor[4:0]==6)?{a_sub[5:0],a_sub[31:6]}:
(b_xor[4:0]==7)?{a_sub[6:0],a_sub[31:7]}:
(b_xor[4:0]==8)?{a_sub[7:0],a_sub[31:8]}:
(b_xor[4:0]==9)?{a_sub[8:0],a_sub[31:9]}:
(b_xor[4:0]==10)?{a_sub[9:0],a_sub[31:10]}:
(b_xor[4:0]==11)?{a_sub[10:0],a_sub[31:11]}:
(b_xor[4:0]==12)?{a_sub[11:0],a_sub[31:12]}:
(b_xor[4:0]==13)?{a_sub[12:0],a_sub[31:13]}:
(b_xor[4:0]==14)?{a_sub[13:0],a_sub[31:14]}:
(b_xor[4:0]==15)?{a_sub[14:0],a_sub[31:15]}:
(b_xor[4:0]==16)?{a_sub[15:0],a_sub[31:16]}:
(b_xor[4:0]==17)?{a_sub[16:0],a_sub[31:17]}:
(b_xor[4:0]==18)?{a_sub[17:0],a_sub[31:18]}:
(b_xor[4:0]==19)?{a_sub[18:0],a_sub[31:19]}:
(b_xor[4:0]==20)?{a_sub[19:0],a_sub[31:20]}:
(b_xor[4:0]==21)?{a_sub[20:0],a_sub[31:21]}:
(b_xor[4:0]==22)?{a_sub[21:0],a_sub[31:22]}:
(b_xor[4:0]==23)?{a_sub[22:0],a_sub[31:23]}:
(b_xor[4:0]==24)?{a_sub[23:0],a_sub[31:24]}:
(b_xor[4:0]==25)?{a_sub[24:0],a_sub[31:25]}:
(b_xor[4:0]==26)?{a_sub[25:0],a_sub[31:26]}:
(b_xor[4:0]==27)?{a_sub[26:0],a_sub[31:27]}:
(b_xor[4:0]==28)?{a_sub[27:0],a_sub[31:28]}:
(b_xor[4:0]==29)?{a_sub[28:0],a_sub[31:29]}:
(b_xor[4:0]==30)?{a_sub[29:0],a_sub[31:30]}:
(b_xor[4:0]==31)?{a_sub[30:0],a_sub[31]}:
a_sub;
assign a_xor = a_rot ^ b_xor;

// Sequential Circuit for Block B
always@(posedge clk)begin
    if(!clr)
       b_reg <= 0;
    else if(state == ST_PRE_ROUND)
        b_reg <= din[31:0];
    else if(state == ST_ROUND_OP)
       b_reg <= b_xor;       
end

// Sequential Circuit for Block A
always@(posedge clk)
begin
    if(!clr)
       a_reg <= 0;
    else if(state == ST_PRE_ROUND)
       a_reg <= din[63:32];
    else if(state == ST_ROUND_OP)
       a_reg <= a_xor;
end

always @(posedge clk)begin
    if(!clr) 
        state <= ST_IDLE;
    else
        case(state)
            ST_IDLE : if(din_valid)
                        state <= ST_PRE_ROUND;
            ST_PRE_ROUND : state <= ST_ROUND_OP;
            ST_ROUND_OP : if(i_cnt == 4'b0001)
                            state <= ST_READY;
            ST_READY : state <= ST_IDLE;
        endcase                      
end


// Round Counter
always@(posedge clk)
begin
    if(!clr)
        i_cnt <= 4'b1100;
    else if (state == ST_ROUND_OP)
        if(i_cnt == 4'b0001)
            i_cnt <= 4'b1100;
        else
            i_cnt <= i_cnt - 1 ;    
end


endmodule