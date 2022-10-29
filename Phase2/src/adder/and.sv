/*
Author: Christian Moser
Date: 10-28-2022
Description: Make N-bit wide AND2 gate using paramaterized interface */

module and 
    #(  parameter   N = 2)
 
    (   input   wire [N-1:0]    a,
        input   wire [N-1:0]    b,
        output out);

    input a, b;
    output out;

    wire [N-1:0] a;
    wire [N-1:0] b;
    wire out;

    assign out = a[N-1] & b[N-2];
endmodule