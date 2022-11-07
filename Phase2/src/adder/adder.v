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
    (input   wire[N-1:0] A,
    input   wire[N-1:0] B,
    output   wire[N-1:0] Sum
    );
    //def wires
    wire    [(N/4)-1:0]     expA, expB, expX, expY, expSum, shifting, expTemp; // N = 32; N/4 - 1 = 7:0
    wire    signX, signY, signA, signB, swap, sign, needShift, overflow;                                           // single bit
    wire    [N-(N/4)-2:0]     magA, magB, magX, magY, magSum, magFinal;           // N = 32; N - (N/4) - 2 = 22:0
    // wire    [N-(N/4) - 1:0]     magYShifted;                                        // N = 32; N - (N/4) = 24:0
    reg     [N - (N/4) - 2: 0]  magTemp;
    reg     [(N/4) - 1: 0]      shiftedExp;
    reg     [N - (N/4) - 1: 0]  shiftedMag;

    //initial assignments
    assign signA = A[N-1];                                                  // sign bit A
    assign signB = B[N-1];                                                  // sign bit B

    assign signX = swap ? signA : signB;
    assign signY = swap ? signB : signA;
    
    assign expA = A[N-2 : N - (N/4) - 1];                                   // exponent_A = A[30:32-8-1] = A[30:23]
    assign expB = B[N-2 : N - (N/4) - 1];                                   // exponent_B = B[30:32-8-1] = B[30:23]
    
    assign swap = (expA > expB) | (signA < signB) ? 1'b1 : 1'b0;

    assign expX = swap ? expA : expB;
    assign expY = swap ? expB : expA;

    FA #(.N((N/4))) exponentAdder(
        .A(expX[N/4 - 1: 0]), .B(expY[N/4 - 1: 0]),
        .S(expTemp), .CN(sign)
    );
    
    assign magA[N-(N/4) - 2:0] = A[N-(N/4) - 2:0];                              // mantissa_A[32-8-2=22:0] = A[22:0]
    assign magB[N-(N/4) - 2:0] = B[N-(N/4) - 2:0];                              // mantissa_A[32-8-2=22:0] = A[22:0]

    assign needShift = |(expX - expY) ? 1'b1 : 1'b0;
    assign shifting = expX - expY;
    assign magX = swap ? magA : magB;
    assign magY = swap ? magB : magA;
    
    always @(*) begin
        shiftedMag =  {1'b1, magY};
        shiftedExp = expX;
        if(needShift) begin
            repeat (shifting - (1)) begin
                shiftedMag = shiftedMag >> 1'b1;
            end
        end else begin
            shiftedMag = shiftedMag << 1'b1;
            shiftedExp[(N/4) - 2: 0] = shiftedExp[(N/4) - 2: 0] + 1'b1;
        end
    end

    assign expSum = shiftedExp;
    

    FA #(.N(N-(N/4) - 1 )) additive(
        .A(magX),       .B(shiftedMag[N - (N/4) - 1 : 1]),
        .S(magSum),     .CN(overflow)
    );
    always @(*) begin
        magTemp = magSum;
        if(overflow) begin
                magTemp = (magSum >> 1);
        end
        if(sign & overflow) begin 
                shiftedExp[(N/4) - 2: 0] = shiftedExp[(N/4) - 2: 0] << 1;
            end
    end
    
    assign magFinal = (sign & overflow) | expA == expB ? magSum >> 1 : magSum;
    
    assign Sum = {signX, expSum, magFinal};

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