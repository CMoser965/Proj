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
wire    sign;
wire    [8:0]   exp, expSum;
wire    [22:0]  magProd;
wire    [23:0]  opA, opB;
wire    [47:0]  prodTmp, normalizedProd;

assign sign         = A[31] ^ B[31]; // get sign
assign exception    = (&A[30:23]) | (&B[30:23]);

assign opA          = (|A[30:23]) ? {1'b1, A[22:0]} : {1'b0, A[22:0]};
assign opB          = (|A[30:23]) ? {1'b1, B[22:0]} : {1'b0, B[22:0]};

assign prodTmp        = opA * opB;
assign round          = |normalizedProd[22:0];
assign norm           = prodTmp[47] ? 1'b1 : 1'b0;
assign normalizedProd = norm ? prod : prod << 1;
assign zero           = exception ? 1'b0 : (magProd == 23'b0) ? 1'b1 : 1'b0;
assign expSum         = A[30:23] + B[30:23];
assign exp            = expSum - 8'd127 + norm;

assign overflow     =  ((exp[8] & !exp[7]) & !zero);
assign underflow    =  ((exp[8] & exp[7]) & !zero) ? 1'b1 : 1'b0;

assign prod         =  exception ? 32'd0 : zero ? {sign, 31'd0} : overflow ? {sign, 8'hFF, 23'd0} : underflow ? {sign, 31'd0} : {sign, exp[7:0], magProd};
endmodule