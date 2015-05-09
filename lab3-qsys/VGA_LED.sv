/*
 * Avalon memory-mapped peripheral for PLazeR
 */
 
// 320*240*8 = 614400
//                    - 1 = 614399

module VGA_LED(input logic        clk,
	       input logic 	  reset,
	       input logic [1023:0] writedata,
	       input logic 	  write,
	       input 		  chipselect,
			 input logic [8:0] address,

	       output logic [7:0] VGA_R, VGA_G, VGA_B,
	       output logic 	  VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n,
	       output logic 	  VGA_SYNC_n);

			 /*
	logic [614399:0] image;
	 
	VGA_LED_Emulator led_emulator(.clk50(clk), .*);

	genvar i;
	generate
	begin
		for(i = 0; i < 600; i+=1) begin: init_i
			always_ff @(posedge clk) begin
				if (reset) image[i*1024+1023 : i*1024] <= 1024'b0;
				if (chipselect && write) image[i*1024+1023 : i*1024] <= writedata;
			end
		end
		end
	endgenerate
	*/
	
	logic [2311:0] w_pixel_matrix;
	
	  shift_register SHIFT_REG( 
    // input
    .pix_in(8'b11111111), 
    .shift_enable(write), 
   // .n_rst(n_rst), 
    .clear(reset),
    .clk(clk),
	 
	 // output
	 .out(w_pixel_matrix)
    );
	 
	   arit ARITH (
    // input
    .in_pixels(w_pixel_matrix),
    
    // output
    .out_pixel(VGA_R)
    );
	
endmodule
