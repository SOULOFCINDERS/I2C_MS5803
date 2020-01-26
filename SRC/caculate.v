`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module caculate(
input[63:0] D_1A,
input[63:0] D_2A,
input[63:0] D_1B,
input[63:0] D_2B,
input[63:0] D_1C,
input[63:0] D_2C,
output[63:0] PA,
output[63:0] PB,
output[63:0] PC
);

//parameter C_1A = 64'd45343;
//parameter C_2A = 64'd40723;
//parameter C_3A = 64'd29224;
//parameter C_4A = 64'd27732;
//parameter C_5A = 64'd32072;
//parameter C_6A = 64'd29154;

parameter C_1A = 64'd44686;
parameter C_2A = 64'd40284;
parameter C_3A = 64'd27857;
parameter C_4A = 64'd26649;
parameter C_5A = 64'd32473;
parameter C_6A = 64'd28359;

parameter C_1B = 64'd43990;
parameter C_2B = 64'd40100;
parameter C_3B = 64'd27483;
parameter C_4B = 64'd26623;
parameter C_5B = 64'd32507;
parameter C_6B = 64'd28413;

parameter C_1C = 64'd44414;
parameter C_2C = 64'd41062;
parameter C_3C = 64'd27728;
parameter C_4C = 64'd27445;
parameter C_5C = 64'd32564;
parameter C_6C = 64'd28304;

wire[63:0] dT_A;
wire[63:0] TEMP_A;
wire[63:0] OFF_A;
wire[63:0] SENS_A;


assign dT_A = D_2A-(C_5A<<8);
assign TEMP_A = 2000+(dT_A*C_6A>>23);
assign OFF_A = (C_2A<<16)+(C_4A*dT_A>>7);
assign SENS_A = (C_1A<<15)+(C_3A*dT_A>>8);
assign PA = ((D_1A*SENS_A>>21)-OFF_A)>>15;

wire[63:0] dT_B;
wire[63:0] TEMP_B;
wire[63:0] OFF_B;
wire[63:0] SENS_B;


assign dT_B = D_2B-(C_5B<<8);
assign TEMP_B = 2000+(dT_B*C_6B>>23);
assign OFF_B = (C_2B<<16)+(C_4B*dT_B>>7);
assign SENS_B = (C_1B<<15)+(C_3B*dT_B>>8);
assign PB = ((D_1B*SENS_B>>21)-OFF_B)>>15;


wire[63:0] dT_C;
wire[63:0] TEMP_C;
wire[63:0] OFF_C;
wire[63:0] SENS_C;


assign dT_C = D_2C-(C_5C<<8);
assign TEMP_C = 2000+(dT_C*C_6C>>23);
assign OFF_C = (C_2C<<16)+(C_4C*dT_C>>7);
assign SENS_C = (C_1C<<15)+(C_3C*dT_C>>8);
assign PC = ((D_1C*SENS_C>>21)-OFF_C)>>15;

 
endmodule
