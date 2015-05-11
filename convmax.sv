module convmax(
    input logic                 clk,
    input logic [119:0][7:0]    indata,
    input logic [7:0][7:0]      gauss,

    output logic [15:0]         maxval,
    output logic [7:0]          maxpos,
    output logic                ready
);

conv c1(.clk        (clk),
        .data       (indata[4:0]),
        .gauss      (gauss),
        .convvalue  (maxval)
        );

assign maxpos = 0;
assign ready = 1;

endmodule
