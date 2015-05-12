module conv(
    input logic                 clk,
    input logic [15:0][7:0]     data,
    input logic [7:0][7:0]      gauss,

    output logic [16:0]         convvalue
);

logic [15:0][15:0] marr;
logic [19:0] val;

mult m0(data[0], gauss[0], marr[0]);
mult m1(data[1], gauss[1], marr[1]);
mult m2(data[2], gauss[2], marr[2]);
mult m3(data[3], gauss[3], marr[3]);
mult m4(data[4], gauss[4], marr[4]);
mult m5(data[5], gauss[5], marr[5]);
mult m6(data[6], gauss[6], marr[6]);
mult m7(data[7], gauss[7], marr[7]);

mult m15(data[15], gauss[0], marr[15]);
mult m14(data[14], gauss[1], marr[14]);
mult m13(data[13], gauss[2], marr[13]);
mult m12(data[12], gauss[3], marr[12]);
mult m11(data[11], gauss[4], marr[11]);
mult m10(data[10], gauss[5], marr[10]);
mult m9(data[9], gauss[6], marr[9]);
mult m8(data[8], gauss[7], marr[8]);

p_add p0(marr[0], marr[1], marr[2], marr[3],
         marr[4], marr[5], marr[6], marr[7],
         marr[8], marr[9], marr[10], marr[11],
         marr[12], marr[13], marr[14], marr[15],
         val);

assign conv_value = val[19:3];

endmodule
