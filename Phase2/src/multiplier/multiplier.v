/*
Author: Christian Moser
Date: 10-28-2022
Project Description:

Create floating-point multiplier used for MLP neural network implementation.
*/

module multiplier
(   input   [31:0]  A,
    input   [31:0]  B,
    output  exception,
    output  overflow,
    output  underflow,
    output  [31:0]  prod
);

//def wires
wire    sign, signA, signB, isNormal, round, expSumCarry, expSumCarryNorm;
wire    [7:0]   expA, expB, expProd, expSum;
wire    [22:0]  magA, magB, magProd;
wire    [47:0]  magTemp, normalTemp;


assign expA = A[30:23];
assign expB = B[30:23];
assign magA = A[22:0];
assign magB = B[22:0];
assign signA = A[31];
assign signB = B[31];
assign sign = signA ^ signB;

FA #(.N(8)) expadder (
    .A(expA), .B(expB),
    .S(expSum), .CN(expSumCarry)
);

assign isNormal   =    magTemp[47] ? 1'b1 : 1'b0;
assign round      =    |normalTemp[22:0];

FA #(.N(8)) expaddernorm (
    .A(expSum), .B(8'b10000001 + isNormal),
    .S(expProd), .CN(expSumCarryNorm)
);

assign magTemp    =    {(|expA) ? 1'b1 : 1'b0, magA} * {(|expB) ? 1'b1 : 1'b0, magB};
assign normalTemp =    isNormal ? magTemp : magTemp << isNormal;
assign magProd    =    normalTemp[46:24] + (normalTemp[23] & round);

assign exception =  (&expA) | (&expB);
assign zero      =  exception ? 1'b0 : ({isNormal, magProd[21:0]} == 23'b0) & ~expSumCarry;
assign overflow  =  ((expSumCarry & !expProd[7]) & !zero);
assign underflow =  ((expSumCarryNorm & expProd[7]) & !zero);

assign prod = exception ? 32'd0                   : 
              zero      ? {sign, 31'd0}           :
              overflow  ? {sign, 8'hFF, 23'd0}    :
              underflow ? {sign, 31'd0}           :
                          {sign, expProd, magProd};

endmodule

module FA #(parameter N = 32) (
    input wire[N-1:0] A,
    input wire[N-1:0] B,
    output wire[N-1:0] S,
    output wire CN
);

    wire [N:0] sum;
    wire [N-2:0] carrier;
    wire [N-1:0] FAResult;

    Cell rippleCarry [N-1:0] (
        .A(A),
        .B(B),
        .Cin({carrier, 1'b0}),
        .Sum(FAResult),
        .Cout({CN, carrier})
    ); 

    assign sum = {CN, FAResult};

    assign S = FAResult;

endmodule

module Cell (
    input A,
    input B,
    input Cin,
    output Sum,
    output Cout
);

    assign Sum = A ^ B ^ Cin;
    assign Cout = (A & B) | (B & Cin) | (A & Cin); 

endmodule