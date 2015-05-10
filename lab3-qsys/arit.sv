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

logic[15:0] coefficients[0:288] = '{16'd0, 16'd0, 16'd1, 16'd1, 16'd2, 16'd3, 16'd3, 16'd4, 16'd4, 16'd4, 16'd3, 16'd3, 16'd2, 16'd1, 16'd1, 16'd0, 16'd0, 16'd0, 16'd1, 16'd1, 16'd2, 16'd4, 16'd6, 16'd8, 16'd9, 16'd10, 16'd9, 16'd8, 16'd6, 16'd4, 16'd2, 16'd1, 16'd1, 16'd0, 16'd1, 16'd1, 16'd3, 16'd5, 16'd8, 16'd12, 16'd16, 16'd19, 16'd20, 16'd19, 16'd16, 16'd12, 16'd8, 16'd5, 16'd3, 16'd1, 16'd1, 16'd1, 16'd2, 16'd5, 16'd9, 16'd15, 16'd22, 16'd29, 16'd34, 16'd36, 16'd34, 16'd29, 16'd22, 16'd15, 16'd9, 16'd5, 16'd2, 16'd1, 16'd2, 16'd4, 16'd8, 16'd15, 16'd25, 16'd36, 16'd48, 16'd57, 16'd60, 16'd57, 16'd48, 16'd36, 16'd25, 16'd15, 16'd8, 16'd4, 16'd2, 16'd3, 16'd6, 16'd12, 16'd22, 16'd36, 16'd54, 16'd71, 16'd84, 16'd89, 16'd84, 16'd71, 16'd54, 16'd36, 16'd22, 16'd12, 16'd6, 16'd3, 16'd3, 16'd8, 16'd16, 16'd29, 16'd48, 16'd71, 16'd94, 16'd111, 16'd117, 16'd111, 16'd94, 16'd71, 16'd48, 16'd29, 16'd16, 16'd8, 16'd3, 16'd4, 16'd9, 16'd19, 16'd34, 16'd57, 16'd84, 16'd111, 16'd131, 16'd138, 16'd131, 16'd111, 16'd84, 16'd57, 16'd34, 16'd19, 16'd9, 16'd4, 16'd4, 16'd10, 16'd20, 16'd36, 16'd60, 16'd89, 16'd117, 16'd138, 16'd146, 16'd138, 16'd117, 16'd89, 16'd60, 16'd36, 16'd20, 16'd10, 16'd4, 16'd4, 16'd9, 16'd19, 16'd34, 16'd57, 16'd84, 16'd111, 16'd131, 16'd138, 16'd131, 16'd111, 16'd84, 16'd57, 16'd34, 16'd19, 16'd9, 16'd4, 16'd3, 16'd8, 16'd16, 16'd29, 16'd48, 16'd71, 16'd94, 16'd111, 16'd117, 16'd111, 16'd94, 16'd71, 16'd48, 16'd29, 16'd16, 16'd8, 16'd3, 16'd3, 16'd6, 16'd12, 16'd22, 16'd36, 16'd54, 16'd71, 16'd84, 16'd89, 16'd84, 16'd71, 16'd54, 16'd36, 16'd22, 16'd12, 16'd6, 16'd3, 16'd2, 16'd4, 16'd8, 16'd15, 16'd25, 16'd36, 16'd48, 16'd57, 16'd60, 16'd57, 16'd48, 16'd36, 16'd25, 16'd15, 16'd8, 16'd4, 16'd2, 16'd1, 16'd2, 16'd5, 16'd9, 16'd15, 16'd22, 16'd29, 16'd34, 16'd36, 16'd34, 16'd29, 16'd22, 16'd15, 16'd9, 16'd5, 16'd2, 16'd1, 16'd1, 16'd1, 16'd3, 16'd5, 16'd8, 16'd12, 16'd16, 16'd19, 16'd20, 16'd19, 16'd16, 16'd12, 16'd8, 16'd5, 16'd3, 16'd1, 16'd1, 16'd0, 16'd1, 16'd1, 16'd2, 16'd4, 16'd6, 16'd8, 16'd9, 16'd10, 16'd9, 16'd8, 16'd6, 16'd4, 16'd2, 16'd1, 16'd1, 16'd0, 16'd0, 16'd0, 16'd1, 16'd1, 16'd2, 16'd3, 16'd3, 16'd4, 16'd4, 16'd4, 16'd3, 16'd3, 16'd2, 16'd1, 16'd1, 16'd0, 16'd0};

byte pixels[289];

genvar i, j;
generate
begin
	for(i = 0; i < 17; i+=1) begin: init_i
		for(j = 0; j < 17; j+=1) begin: init_j
		always_comb begin
			pixels[i*17+j] <= in_pixels[(i*17+j)*8+7 : (i*17+j)*8];
		end
	end
	end
	end
endgenerate

logic[15:0] val[0:289], coesum[0:289];
assign val[0] = 16'b0;
assign coesum[0] = 16'b0;

genvar di, dj;
generate
begin
	for(di = -8; di <= 8; di+=1) begin: init_di
		for(dj = -8; dj <= 8; dj+=1) begin: init_dj
			localparam integer index = (di+8)*17 + dj+8;
			assign val[index+1] = val[index] + pixels[index] * coefficients[index];
			assign coesum[index+1] = coesum[index] + coefficients[index];
		end
	end
end
endgenerate

assign out_pixel = val[289]/coesum[289];

endmodule
