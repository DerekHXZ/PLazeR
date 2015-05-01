module simple_counter (input logic clk,
							  output logic [31:0] counter_out);
	always_ff @(posedge clk)
	begin
		counter_out <= counter_out + 1;
	end
endmodule