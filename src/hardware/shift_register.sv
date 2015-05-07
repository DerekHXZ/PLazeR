// $Id: $
// File name:   shift_register.sv
// Created:     11/23/2014
// Author:      Aiman
// Version:     1.0  Initial Design Entry
// Description: A shift register that shifts one pixel (8 bit) each time.

module shift_register (
  output [71:0] out,
  input [7:0] pix_in,
  input shift_enable,
  input n_rst, clear, clk
  );

genvar k;
generate
	for (k = 0; k < 9; k = k + 1) begin: shiftgen
		always_ff @ (posedge clk, negedge n_rst) begin : SR
		  if(n_rst == 1'b0) begin
			 out[k*8+7:k*8] <= 8'b0;
		  end
		  else if(shift_enable == 1 && clear == 0) begin
		    if(k==0) begin
				out[7:0] <= pix_in;
			 end
			 else begin
				out[k*8+7:k*8] <= out[k*8-1:k*8-8];
			 end
		  end
		  else if(shift_enable == 0 && clear == 0) begin
			 out[k*8+7:k*8] <= out[k*8+7:k*8];
		  end
		  else if(clear == 1) begin
			 out[k*8+7:k*8] <= 8'b0;
		  end
		end
	end
endgenerate

endmodule
