/*
Author: Christian Moser
Date: 10-28-2022
Description: Full-Precision (N-bit) floating point adder implementation

example of 32-bit single precision float:
1   11111111    11111111111111111111111
S   E           M
S = 0 | 1 implies positive (0) or negative (1)
E = 1111 1111 equivalent to whole number component
M = 1111 1111 1111 1111 1111 111 equivalent to decimal component
*/

module adder
    #(parameter N=32)
    (input  clk,
    input   wire[N-1:0] A,
    input   wire[N-1:0] B,
    output   wire[N-1:0] Sum
    );

    //def ports
    input   clk;
    input   [N-1:0]   A, B;
    output  [N-1:0]   Sum

    //def wires
    wire    [(N/4)-1:0]     expA, expB, expOp1, expOp2, expSum, expOp1Hold;
    wire    signA, signB, signSum, signOp1, signOp2;
    wire    [N-(N/4)-1:0]     magA, magB, magOp1, magOp2, magSum;
    wire    [N-(N/4):0]     magHold;

    //initial assignments
    assign signA = A[N-1];
    assign signB = B[N-1];
    assign expA = A[N-2:(N-1)-(N/4)];
    assign expB = B[N-2:(N-1)-(N/4)];
    assign magA[N-(N/4)-1] = 1'b1;
    assign magB[N-(N/4)-1] = 1'b1;
    assign magA[N-(N/4)-2:0] = A[N-(N/4)-1:0];
    assign magB[N-(N/4)-2:0] = B[N-(N/4)-1:0];

    shiftreg cmpshift(expA, expB, signA, signB, magA, magB, clk, expOp1, expOp2, magOp1, magOp2, signSum, signOp1, signOp2);
    fadd ALU(magA, magB, signOp1, signOp2, signSum, expOp1, clk, magHold, expOp1Hold, expOp2, signOp2);
    normalizer(magHold, signOp2, )
    


endmodule

module minALU()

module fadd(a,b,s1,s2,sn,ex1,clk,out,ex2,sn3,sn4,sr1); //submodule for addition
input [23:0]a,b;
input[7:0]ex1;
input s1,s2,clk,sn;
output reg [7:0]ex2;
output reg[24:0]out;
output reg sn3,sn4,sr1;
always@(posedge clk)
begin
ex2=ex1;
sr1=sn;
sn3=s1;
sn4=s2;
out=a+b;
end
endmodule

module shiftreg(
    input   [(N/4)-1:0] expA,
    input   [(N/4)-1:0] expB,
    output   [(N/4)-1:0] expOp1,
    output   [(N/4)-1:0] expOp2,
    input   clk, 
    input   signA, 
    input   signB,
    output   signSum,
    input   [N-(N/4)-1:0] magA,
    input   [N-(N/4)-1:0] magB,
    output   [N-(N/4)-1:0] magOp1,
    output   [N-(N/4)-1:0] magOp2,
)

    //def ports
    input   [(N/4)-1:0] expA, expB;
    input   clk, signA, signB, signSum;
    input   [N-(N/4)-1:0] magA, magB;

    output reg[(N/4)-1:0] expOp1, expOp2;
    output reg[N-(N/4)-1:0] magOp1, magOp2;
    output reg signSum;

    reg[(N-4)-1:0] diff;

    always @(posedge clk) begin
        signOp1 = signA;
        signOp2 = signB;


        if(expA == expB) begin
            expOp1 = expA + 8'b1;
            expOp2 = expB + 8'b1;

            magOp1 = magA;
            magOp2 = magB;

            signSum = 1'b1;
        end

        else if(expA > expB) begin
            diff = expA - expB;
            expOp1 = expA + 8'b1;
            expOp2 = expB + 8'b1;

            magOp1 = magA;
            magOp2 = magB >> diff;
            
            signSum = 1'b1;
        end

        else if(expB > expA) begin 
            diff = expB - expA;
            expOp1 = expB + 8'b1;
            expOp2 = expA + 8'b1;

            magOp1 = magB;
            magOp2 = magA >> diff;
            
            signSum = 1'b0;
        end
    end


endmodule

module normalizer(
    input    [N-(N/4):0]     magHold,
    input    [(N/4)-1:0]     signA,
    input    [(N/4)-1:0]     signB,
    input   signSum,
    input   signOp1,
    input   signOp2,
    input   clk,
    input   [(N/4)-1:0]     expOp1,
    output  [N-(N/4)-1:0]   magOp1, 
    output  [N-(N/4)-1:0]   magOp2,
    output  [N-(N/4)-1:0]   magSum
)

    //def ports
    input    [N-(N/4):0]     magHold;
    input    [(N/4)-1:0]     signA, signB;
    input   signSum, signOp1, signOp2, clk;
    input   [(N/4)-1:0]     expOp1,
    output reg [N-(N/4)-1:0]   magOp1; 
    output reg [N-(N/4)-1:0]   magOp2;
    output  [N-(N/4)-1:0]   magSum;

    always @(posedge clk) begin
        magSum = magHold[N-(N/4):1];
        expSum = expA;
        repeat(N-(N/4)) begin

            if(magSum[N-(N/4)-1] == 1'b0) begin
                magSum = magSum << 1'b1;
                expSum = expSum - 8'b1;
            end
        end
    end
endmodule

