module convmax(
    input logic                 clk,
    input logic [119:0][7:0]    indata,
    input logic [7:0][7:0]      gauss,

    output logic [15:0]         maxval,
    output logic [7:0]          maxpos,
    output logic                ready
);

//conv c1(.clk        (clk),
  //      .data       (indata[15:0]),
    //    .gauss      (gauss),
      //  .convvalue  (maxval)
        //);
logic[15:0] val[0:103];
logic[15:0] maxval_so_far[0:103];
logic[7:0] maxpos_so_far[0:103];

assign maxval_so_far[0] = val[0];
assign maxpos_so_far[0] = 8'b0;

genvar i;
generate
begin
	for( i = 0; i < 104; i++ ) begin: for_i
		conv (.clk        (clk),       //input
		.data       (indata[i+15:i]),     // input
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

assign max_val = maxval_so_far[103];
assign maxpos = maxpos_so_far[103];
assign ready = 1;

endmodule
