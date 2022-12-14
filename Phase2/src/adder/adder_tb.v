module stimulus();

    reg     [31:0]  A,  B;
    reg     clk;
    wire    [31:0]  out;

    adder #(.N(32)) DUT(A, B, clk, out);
    initial begin
        // A = 32'b01000011000101100000000000000000; // 150
        // B = 32'b01000000001000000000000000000000; // 2.5
        A = 32'b01000000011100000000000000000000; // 3.75
        B = 32'b01000000110010000000000000000000; // 6.25
        // A = 32'b01000000000010000000000000000000; // 2.125
        // B = 32'b01000000000010000000000000000000; // 2.125
    end
    
    
endmodule