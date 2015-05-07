// $Id: $
// File name:   arit.sv
// Created:     11/13/2014
// Modified:    11/23/2014
// Author:      Saulo Cesar Rodrigues Pereira Sobrinho
// Project 
// Version:     1.0  Initial Design Entry
// Description: Arithmetic block.

module arit
(
  input [2311:0]in_pixels,  //input from shift register
  output [7:0]out_pixel   //output to output logic block
);

byte pixels[289];

genvar i, j;
generate
begin
	for(i = 0; i < 17; i+=1) begin: init_i
		for(j = 0; j < 17; j+=1) begin: init_j
		always_comb begin
			pixels[i*j] <= in_pixels[(i*17+j)*8+7 : (i*17+j)*8];
		end
	end
	end
	end
endgenerate

genvar di, dj;
generate
begin
	real val = 0, wsum = 0;
	for(di = -8; di <= 8; di+=1) begin: init_di
		for(dj = -8; dj <= 8; dj+=1) begin: init_dj			
			int dsq = di * di + dj * dj;
			real w = exp(-dsq / 2.0) / 6.28;
			
			always_comb begin
				int index = (di+8)*17 + dj+8;
				val += pixels[index] * w;
				wsum += w;
			end
		end
	end
end
endgenerate

assign out_pixel = round(val/wsum);

endmodule
