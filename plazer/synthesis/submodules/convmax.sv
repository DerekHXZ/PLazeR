module convmax(
    input logic                 clk,
    input logic [7:0]           indata[0:47],
    input logic [7:0]           gauss[0:7],

	 output logic [15:0]         val[0:31],
    output logic [15:0]         maxval,
    output logic [7:0]          maxpos,
    output logic                ready
);

logic[15:0] maxval_so_far[0:31];
logic[7:0]  maxpos_so_far[0:31];

assign maxval_so_far[0] = 16'b0;
assign maxpos_so_far[0] = 8'b0;

genvar i;
generate
begin
    for( i = 0; i < 32; i++ ) begin: for_i
        conv(.clk        (clk),       //input
             .data       (indata[i:i+15]),     // input
             .gauss      (gauss),              //input
             .convvalue  (val[i])     // output [16:0]  convvalue
        );
        if (i>0) begin
            assign maxval_so_far[i] = (maxval_so_far[i-1] > val[i]) ? maxval_so_far[i-1] : val[i];
            assign maxpos_so_far[i] = (maxval_so_far[i-1] > val[i]) ? maxpos_so_far[i-1] : i;
        end
    end
end
endgenerate

assign maxval = maxval_so_far[31];
assign maxpos = maxpos_so_far[31];
assign ready = 1;

endmodule
